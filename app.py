#!/usr/bin/env python3
"""
XYZ Corp Project Management API
Flask-based REST API for project and task management
"""

import os
import sqlite3
from datetime import datetime
from functools import wraps
from flask import Flask, request, jsonify

app = Flask(__name__)
DATABASE = os.path.join(os.path.dirname(__file__), 'projects.db')

with app.app_context():
    def init_db():
        conn = sqlite3.connect(DATABASE)
        cursor = conn.cursor()
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS projects (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                description TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS tasks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                project_id INTEGER NOT NULL,
                title TEXT NOT NULL,
                status TEXT NOT NULL CHECK(status IN ('todo', 'in-progress', 'done')),
                assigned_to TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
            )
        ''')
        conn.commit()
        conn.close()
    init_db()

def get_db():
    conn = sqlite3.connect(DATABASE)
    conn.row_factory = sqlite3.Row
    return conn

# ============================================================================
# ERROR HANDLERS
# ============================================================================

@app.errorhandler(404)
def not_found(error):
    return jsonify({
        'error': 'Resource not found',
        'status': 404,
        'message': 'The requested resource does not exist'
    }), 404

@app.errorhandler(400)
def bad_request(error):
    return jsonify({
        'error': 'Bad request',
        'status': 400,
        'message': 'Invalid request parameters'
    }), 400

def handle_db_error(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        try:
            return f(*args, **kwargs)
        except sqlite3.IntegrityError as e:
            return jsonify({
                'error': 'Database integrity error',
                'status': 400,
                'message': str(e)
            }), 400
        except sqlite3.Error as e:
            return jsonify({
                'error': 'Database error',
                'status': 500,
                'message': str(e)
            }), 500
    return decorated_function

# ============================================================================
# HEALTH CHECK
# ============================================================================

@app.route('/api/health', methods=['GET'])
def health_check():
    return jsonify({
        'status': 'healthy',
        'service': 'XYZ Corp Project Management API',
        'timestamp': datetime.now().isoformat(),
        'database': 'operational'
    }), 200

# ============================================================================
# PROJECTS ENDPOINTS
# ============================================================================

@app.route('/api/projects', methods=['GET'])
@handle_db_error
def get_projects():
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute('SELECT id, name, description, created_at FROM projects')
    rows = cursor.fetchall()
    conn.close()
    projects = [
        {
            'id': row['id'],
            'name': row['name'],
            'description': row['description'],
            'created_at': row['created_at']
        }
        for row in rows
    ]
    return jsonify({
        'status': 'success',
        'data': projects,
        'count': len(projects)
    }), 200

@app.route('/api/projects', methods=['POST'])
@handle_db_error
def create_project():
    data = request.get_json()
    if not data:
        return jsonify({
            'error': 'Bad request',
            'status': 400,
            'message': 'Request body must be JSON'
        }), 400
    if 'name' not in data or not data['name']:
        return jsonify({
            'error': 'Bad request',
            'status': 400,
            'message': 'Project name is required'
        }), 400
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute(
        'INSERT INTO projects (name, description) VALUES (?, ?)',
        (data['name'], data.get('description', ''))
    )
    conn.commit()
    project_id = cursor.lastrowid
    conn.close()
    return jsonify({
        'status': 'success',
        'message': 'Project created successfully',
        'data': {
            'id': project_id,
            'name': data['name'],
            'description': data.get('description', ''),
            'created_at': datetime.now().isoformat()
        }
    }), 201

# ============================================================================
# TASKS ENDPOINTS
# ============================================================================

@app.route('/api/projects/<int:project_id>/tasks', methods=['GET'])
@handle_db_error
def get_project_tasks(project_id):
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute('SELECT id FROM projects WHERE id = ?', (project_id,))
    if not cursor.fetchone():
        conn.close()
        return jsonify({
            'error': 'Not found',
            'status': 404,
            'message': f'Project with id {project_id} not found'
        }), 404
    cursor.execute(
        'SELECT id, project_id, title, status, assigned_to, created_at FROM tasks WHERE project_id = ?',
        (project_id,)
    )
    rows = cursor.fetchall()
    conn.close()
    tasks = [
        {
            'id': row['id'],
            'project_id': row['project_id'],
            'title': row['title'],
            'status': row['status'],
            'assigned_to': row['assigned_to'],
            'created_at': row['created_at']
        }
        for row in rows
    ]
    return jsonify({
        'status': 'success',
        'data': tasks,
        'count': len(tasks)
    }), 200

@app.route('/api/tasks', methods=['POST'])
@handle_db_error
def create_task():
    data = request.get_json()
    if not data:
        return jsonify({
            'error': 'Bad request',
            'status': 400,
            'message': 'Request body must be JSON'
        }), 400
    required_fields = ['project_id', 'title', 'status']
    for field in required_fields:
        if field not in data:
            return jsonify({
                'error': 'Bad request',
                'status': 400,
                'message': f'{field} is required'
            }), 400
    valid_statuses = ['todo', 'in-progress', 'done']
    if data['status'] not in valid_statuses:
        return jsonify({
            'error': 'Bad request',
            'status': 400,
            'message': f'Status must be one of: {", ".join(valid_statuses)}'
        }), 400
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute('SELECT id FROM projects WHERE id = ?', (data['project_id'],))
    if not cursor.fetchone():
        conn.close()
        return jsonify({
            'error': 'Bad request',
            'status': 400,
            'message': f'Project with id {data["project_id"]} does not exist'
        }), 400
    cursor.execute(
        'INSERT INTO tasks (project_id, title, status, assigned_to) VALUES (?, ?, ?, ?)',
        (data['project_id'], data['title'], data['status'], data.get('assigned_to'))
    )
    conn.commit()
    task_id = cursor.lastrowid
    conn.close()
    return jsonify({
        'status': 'success',
        'message': 'Task created successfully',
        'data': {
            'id': task_id,
            'project_id': data['project_id'],
            'title': data['title'],
            'status': data['status'],
            'assigned_to': data.get('assigned_to'),
            'created_at': datetime.now().isoformat()
        }
    }), 201

@app.route('/api/tasks/<int:task_id>', methods=['PUT'])
@handle_db_error
def update_task(task_id):
    data = request.get_json()
    if not data:
        return jsonify({
            'error': 'Bad request',
            'status': 400,
            'message': 'Request body must be JSON'
        }), 400
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM tasks WHERE id = ?', (task_id,))
    task = cursor.fetchone()
    if not task:
        conn.close()
        return jsonify({
            'error': 'Not found',
            'status': 404,
            'message': f'Task with id {task_id} not found'
        }), 404
    if 'status' in data:
        valid_statuses = ['todo', 'in-progress', 'done']
        if data['status'] not in valid_statuses:
            conn.close()
            return jsonify({
                'error': 'Bad request',
                'status': 400,
                'message': f'Status must be one of: {", ".join(valid_statuses)}'
            }), 400
    title = data.get('title', task['title'])
    status = data.get('status', task['status'])
    assigned_to = data.get('assigned_to', task['assigned_to'])
    cursor.execute(
        'UPDATE tasks SET title = ?, status = ?, assigned_to = ? WHERE id = ?',
        (title, status, assigned_to, task_id)
    )
    conn.commit()
    conn.close()
    return jsonify({
        'status': 'success',
        'message': 'Task updated successfully',
        'data': {
            'id': task_id,
            'project_id': task['project_id'],
            'title': title,
            'status': status,
            'assigned_to': assigned_to,
            'created_at': task['created_at']
        }
    }), 200

@app.route('/api/tasks/<int:task_id>', methods=['DELETE'])
@handle_db_error
def delete_task(task_id):
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute('SELECT id FROM tasks WHERE id = ?', (task_id,))
    if not cursor.fetchone():
        conn.close()
        return jsonify({
            'error': 'Not found',
            'status': 404,
            'message': f'Task with id {task_id} not found'
        }), 404
    cursor.execute('DELETE FROM tasks WHERE id = ?', (task_id,))
    conn.commit()
    conn.close()
    return jsonify({
        'status': 'success',
        'message': 'Task deleted successfully',
        'data': {
            'id': task_id,
            'deleted': True
        }
    }), 200

# ============================================================================
# APPLICATION ENTRY POINT
# ============================================================================

if __name__ == '__main__':
    raw_port = os.environ.get('PORT', '5000')
    try:
        port = int(raw_port)
        if not (1 <= port <= 65535):
            port = 5000
    except ValueError:
        port = 5000
    app.run(host='0.0.0.0', port=port, debug=False)
