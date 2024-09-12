import pandas as pd
import psycopg2
import hashlib
import random
import string
import datetime


# Function to fetch license table and return it as a DataFrame
def get_license_table():
    # Database connection details
    conn = psycopg2.connect(
        host="44.206.249.55",
        database="dreamchain",
        user="postgres",
        password="DreamChainPgHHHJuIkLoHmNhYYuiNkjfaw"
    )
    
    # SQL query to fetch data from the license table
    query = "SELECT * FROM ACCOUNTS.LICENSE"
    
    # Using pandas to execute the query and return the results as a DataFrame
    df = pd.read_sql(query, conn)
    
    # Close the connection
    conn.close()
    
    return df








# Function to generate a random license key
def generate_license_key():
    random_string = ''.join(random.choices(string.ascii_uppercase + string.digits, k=16))
    license_key = hashlib.sha256(random_string.encode()).hexdigest()
    return license_key

# Function to insert new licenses into the license table
def RegisterKey(license_type):
    # Database connection details
    conn = psycopg2.connect(
        host="44.206.249.55",
        database="dreamchain",
        user="postgres",
        password="DreamChainPgHHHJuIkLoHmNhYYuiNkjfaw"
    )
    
    cursor = conn.cursor()
    
    # Generate new license key
    new_license_key = generate_license_key()
    
    # SQL query to insert the new license
    insert_query = """
    INSERT INTO ACCOUNTS.LICENSE (license_key,license_type,issued_date,status) 
    VALUES (%s,%s,%s,%s)
    """
    # Execute the query and commit the changes
    cursor.execute(insert_query, (new_license_key,license_type,datetime.datetime.now(),'ACTIVE',))
    conn.commit()
    
    # Close the connection
    cursor.close()
    conn.close()
    print("New license key inserted.")
    return new_license_key

def authKey(key):
    df=get_license_table().dropna(subset=['license_key'])
    df=df[df['license_key']==key]
    if len(df)>0:
        return True
    else:
        return False
        
# # Example usage
# RegisterKey('TEST')
# authKey('*************')
# get_license_table()

