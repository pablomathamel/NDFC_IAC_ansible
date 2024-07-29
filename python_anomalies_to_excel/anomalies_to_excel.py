import json
import pandas as pd

# Specify the path to your JSON file
json_file = './anomalies_list.json'  

# Open and read the JSON file
with open(json_file, 'r') as file:
    data = json.load(file)

all_anomalies=[]

for A in data["entries"]:
    single_anomaly=[]
    single_anomaly.append(A["anomalyReason"])
    single_anomaly.append(A["severity"])
    single_anomaly.append(A["category"])
    single_anomaly.append(A["fabricName"])
    single_anomaly.append(A["startDate"])
    single_anomaly.append(A["mnemonicTitle"])
    single_anomaly.append(A["nodeNames"])
    if not A["clearDate"]:  
        single_anomaly.append("Active")
    else:
        single_anomaly.append("Cleared")
    single_anomaly.append(A["endDate"])
    single_anomaly.append(A["clearDate"])  
    all_anomalies.append(single_anomaly)
  


# Convert the list to a Pandas DataFrame
df = pd.DataFrame(all_anomalies, columns=["What's wrong","Anomaly Level","Category","Site","Detection Time","Title","Nodes","Status","Last Seen Time","Cleared"])

# Specify the name of the Excel file
excel_file = './anomalies_list.xlsx'  # Replace 'data.xlsx' with the desired Excel file name

# Export the data to an Excel file
df.to_excel(excel_file, index=False)
print(f'Data exported to {excel_file}')
