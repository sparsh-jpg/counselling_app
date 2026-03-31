import pandas as pd
import json

file = "josaa.xlsx"

df = pd.read_excel(file, engine="openpyxl")

data = []

for _, row in df.iterrows():
    data.append({
        "college": str(row["Institute"]),
        "branch": str(row["Program"]),
        "quota": str(row["Quota"]),
        "category": str(row["Category"]),
        "gender": str(row["Gender"]),
        "opening": int(row["Opening Rank"]),
        "closing": int(row["Closing Rank"]),
    })

with open("../assets/cutoffs.json", "w") as f:
    json.dump(data, f, indent=2)

print("✅ cutoffs.json created successfully!")
