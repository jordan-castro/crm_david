import mysql.connector


mydb = mysql.connector.connect(
    host="localhost",
    user="root",
    password="root"
)

mydb.run