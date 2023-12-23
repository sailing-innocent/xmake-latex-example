import argparse 
import json 

def latex_content(content):
    content = content.replace("_", " ")
    return content

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--json", type=str, default="main.json")
    parser.add_argument("--target", type=str, default="main.tex")
    args = parser.parse_args()
    with open(args.json, "r") as f:
        table_json = json.load(f)
    len_cols = len(table_json["cols"])
    len_rows = len(table_json["rows"])
    if len_rows > 0:
        len_cols = len_cols + 1
    with open(args.target, "w") as f:
        f.write("\\begin{center}\n")
        # caption
        if ("caption" in table_json.keys()):
            caption = latex_content(table_json["caption"])
            f.write("\\caption{" + caption + "}\n")
        # label
        if ("label" in table_json.keys()):
            f.write("\\label{" + table_json["label"] + "}\n")
        # tabular
        f.write("\\begin{tabular}{|")
        f.write("c|" * len_cols)
        f.write("}\n")

        # header
        f.write("\\hline\n")
        if len_rows > 0:
            f.write("& ")
        for col in table_json["cols"][:-1]:
            f.write(latex_content(str(col)) + " & ")
        f.write(latex_content(str(table_json["cols"][-1])))
        f.write("\\\\ \\hline\n")

        # content
        for idx, row in enumerate(table_json["data"]):
            if len_rows > 0:
                content = latex_content(str(table_json["rows"][idx]))
                f.write(content + " & ")
            for item in row[:-1]:
                f.write(latex_content(str(item)) + " & ")
            f.write(latex_content(str(row[-1])))
            f.write("\\\\ \\hline\n")
        f.write("\\end{tabular}\n")
        f.write("\\end{center}\n")