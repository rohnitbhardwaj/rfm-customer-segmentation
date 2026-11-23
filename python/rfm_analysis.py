import pandas as pd

# Importing Cleaned CSV File Data To Python
df = pd.read_csv('retail_cleaned.csv',na_values='Null',sep=',',header=None,
                 names=['invoice','stock_code','description','invoice_date','quantity','price','customer_id','country','source_sheet'])

print(df.dtypes) #Verifying Data Types

df['invoice_date'] = pd.to_datetime(df['invoice_date']) #Convert to Datetime 
df['quantity'] = df['quantity'].astype(int) #Convert str to int

# =====================================================================

# Filter & Calculating Recency, Frequency, Monetary
rfs_data = df[(df['customer_id'].notna())&(df['quantity'] > 0)].copy() #Filtering Out Null & -Ve Qtys AND Creating Copy Of It
rfs_data['total'] = rfs_data['quantity'] * rfs_data['price']

snapshot_date = pd.to_datetime('2011-12-10')


# =====================================================================
# Grouping Customers By RFS, Giving Scores Accordingly & Assign Business Segments
rfs = rfs_data.groupby('customer_id').agg(
    Recency = ('invoice_date', lambda x: (snapshot_date - x.max()).days),
    Frequency = ('invoice','nunique'),
    Monetary = ('total','sum')
).reset_index()

rfs['R_Score'] = pd.qcut(rfs['Recency'], 5, labels=[5,4,3,2,1]).astype(int)
rfs['F_Score'] = pd.qcut(rfs['Frequency'].rank(method='first'), 5, labels=[1,2,3,4,5]).astype(int)
rfs['M_Score'] = pd.qcut(rfs['Monetary'], 5, labels=[1,2,3,4,5]).astype(int)

def segment_customer(row):
    if row['R_Score'] >= 4 and row['F_Score'] >= 4 and row['M_Score'] >= 4:
        return 'Champions'
    elif row['R_Score'] >= 3 and row['F_Score'] >= 3:
        return 'Loyal'
    elif row['R_Score'] <= 2 and row['F_Score'] >= 3:
        return 'At Risk'
    elif row['R_Score'] >= 4 and row['F_Score'] <= 2:
        return 'New'
    elif row['R_Score'] == 3 and row['F_Score'] <= 2:
        return 'Require Attention'
    else:
        return 'Lost'

rfs['segment'] = rfs.apply(segment_customer,axis=1)
rfs['ischurned'] = rfs['Recency'] > 90


# =====================================================================
# Filter & Merge Tables, Exporting Clean Data To Excel File
df = df[ (df['customer_id'].notna()) & (df['quantity'] > 0) ].copy()
df['invoice_month'] = df['invoice_date'].dt.to_period('M').dt.to_timestamp()
df['revenue'] = df['quantity'] * df['price']

df_final = pd.merge(df,rfs,how= 'left',on='customer_id')

df_final.to_excel('ecommerce_dashboard_data.xlsx',na_rep='Null',index=False,sheet_name='Sales_Data',header=True)

print(df_final.head())
