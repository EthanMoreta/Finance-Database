from flask import Flask, render_template, request, redirect
import mysql.connector

app = Flask(__name__)

# Configuración de la base de datos
db_config = {
    'host': 'localhost',
    'user': 'root',  # Cambia esto
    'password': '',  # Cambia esto
    'database': 'finance'
}

# Ruta para mostrar todos los registros
@app.route('/')
def index():
    return render_template('index.html')

# Ruta para mostrar todos los registros
@app.route('/bank_account')
def bank_account():
    return render_template('bank_account.html')

@app.route('/bank_account_search', methods=['POST'])
def bank_account_search():
    first_name = request.form['first_name']
    last_name = request.form['last_name']

    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM bank_account WHERE first_name = %s AND last_name = %s", (first_name,last_name))
    accounts = cursor.fetchall()
    balances = []
    for account in accounts:
        cursor.execute("SELECT get_account_balance(%s)", (account['account_number'],))
        balances.append(cursor.fetchone())
        conn.close()
    balances = [list(item.values())[0] for item in balances]

    conn.close()
    return render_template('bank_account_search.html', accounts=accounts, balances=balances)

# Ruta para mostrar las tarjetas de crédito
@app.route('/credit_card')
def credit_card():
    return render_template('credit_card.html')

# Ruta para mostrar las tarjetas de crédito
@app.route('/credit_card_search', methods=['POST'])
def credit_card_search():
    first_name = request.form['first_name']
    last_name = request.form['last_name']

    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM credit_card WHERE first_name = %s AND last_name = %s", (first_name,last_name))
    cards = cursor.fetchall()
    conn.close()
    return render_template('credit_card_search.html', cards=cards)

# Ruta para mostrar los records
@app.route('/record')
def record():
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM record ")
    records = cursor.fetchall()
    balances = []
    for record in records:
        cursor.execute("SELECT get_record_balance(%s)", (record['record_name'],))
        balances.append(cursor.fetchone())
        conn.close()
    balances = [list(item.values())[0] for item in balances]
    return render_template('record.html', records=records, balances=balances)

@app.route('/add_account')
def add_account():
    return render_template('add_account.html')

@app.route('/add_account_form', methods=['POST'])
def add_account_form():
    account_number = request.form['account_number']
    first_name = request.form['first_name']
    last_name = request.form['last_name']
    bank = request.form['bank']
    opening_date = request.form['opening_date']
    account_type = request.form['account_type']

    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()
    query = """
        INSERT INTO bank_account (account_number, first_name, last_name, bank, opening_date, account_type)
        VALUES (%s, %s, %s, %s, %s, %s)
    """
    cursor.execute(query, (account_number, first_name, last_name, bank, opening_date, account_type))
    conn.commit()
    conn.close()
    return redirect('/bank_account')

@app.route('/add_card')
def add_card():
    return render_template('add_card.html')

@app.route('/add_card_form', methods=['POST'])
def add_card_form():
    card_number = request.form['card_number']
    security_code = request.form['security_code']
    card_type = request.form['card_type']
    first_name = request.form['first_name']
    last_name = request.form['last_name']
    expiration_date = request.form['expiration_date']
    my_account = request.form['my_account']

    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()
    query = """
        INSERT INTO credit_card (card_number, security_code, card_type, first_name, last_name, expiration_date, my_account)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
    """
    cursor.execute(query, (card_number, security_code, card_type, first_name, last_name, expiration_date, my_account))
    conn.commit()
    conn.close()
    return redirect('/credit_card')

# Ruta para eliminar un registro
@app.route('/delete_account/<int:account_number>')
def delete_account(account_number):
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()
    cursor.execute("DELETE FROM bank_account WHERE account_number = %s", (account_number,))
    conn.commit()
    conn.close()
    return redirect('/bank_account')

# Ruta para eliminar una tarjeta
@app.route('/delete_card/<int:card_number>')
def delete_card(card_number):
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()
    cursor.execute("DELETE FROM credit_card WHERE card_number = %s", (card_number,))
    conn.commit()
    conn.close()
    return redirect('/credit_card')

# Ruta para eliminar una tarjeta
@app.route('/delete_record/<int:record_id>')
def delete_record(record_id):
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()
    cursor.execute("DELETE FROM record WHERE record_id = %s", (record_id,))
    conn.commit()
    conn.close()
    return redirect('/record')

# Ruta para eliminar una tarjeta
@app.route('/view_record/<int:record_id>')
def view_record(record_id):
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM movement, register WHERE movement_id = my_movement and my_record = %s", (record_id,))
    movements = cursor.fetchall()
    cursor.execute("SELECT record_name FROM record WHERE record_id = %s", (record_id,))
    record_name = cursor.fetchone()
    conn.close()
    return render_template('movement.html', movements=movements, record_name=record_name)

# Ruta para actualizar un registro
@app.route('/update', methods=['POST'])
def update_account():
    account_number = request.form['account_number']
    first_name = request.form['first_name']
    last_name = request.form['last_name']
    bank = request.form['bank']
    opening_date = request.form['opening_date']
    account_type = request.form['account_type']

    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()
    query = """
        UPDATE bank_account
        SET first_name = %s, last_name = %s, bank = %s, opening_date = %s, account_type = %s
        WHERE account_number = %s
    """
    cursor.execute(query, (first_name, last_name, bank, opening_date, account_type, account_number))
    conn.commit()
    conn.close()
    return redirect('/')

if __name__ == '__main__':
    app.run(debug=True)
