from bs4 import BeautifulSoup
import openpyxl

# Function to extract data from HTML file
def extract_data_from_html(html_file):
    with open(html_file, 'r', encoding='utf-8') as file:
        html_content = file.read()

    soup = BeautifulSoup(html_content, 'html.parser')

    divs = soup.find_all('div', class_='aJfmSs JSmL7R')

    data = []

    for div in divs:
        product_name = ""
        product_price = ""
        product_sold = ""
        ship_from = ""

        product_name_div = div.find('div', {'aria-hidden': 'true', 'class': 'xA2DZd tYvyWM wupGTj'})
        if product_name_div:
            product_name = product_name_div.text.strip()

        product_price_span = div.find('span', class_='_7s1MaR')
        if product_price_span:
            product_price = product_price_span.text.strip()

        product_sold_div = div.find('div', class_='L68Ib9 s3wNiK')
        if product_sold_div:
            product_sold = product_sold_div.text.strip()

        ship_from_div = div.find('div', {'class': 'wZEyNc', 'aria-label': 'from'})
        if ship_from_div:
            ship_from = ship_from_div.text.strip()

        data.append([product_name, product_price, product_sold, ship_from])

    return data

# Extract data from all HTML files
html_files = ['Shopee.html', 'Shopee2.html', 'Shopee3.html']
combined_data = []

for file in html_files:
    data_from_html = extract_data_from_html(file)
    combined_data.extend(data_from_html)

# Write data to Excel file
workbook = openpyxl.Workbook()
worksheet = workbook.active

worksheet.append(['Product Name', 'Product Price', 'Product Sold', 'Ship From'])

for row in combined_data:
    worksheet.append(row)

# Save Excel file
workbook.save('Shopee_chocolate_drink.xlsx')
