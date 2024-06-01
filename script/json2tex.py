import argparse 
import json 
import seaborn as sns

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

    # compare
    # color platte
    rank_num = 0
    rank_metric = "max"
    if "compare" in table_json.keys():
        palette_name = table_json["compare"]["palette"] if "palette" in table_json["compare"].keys() else "RdYlGn"
        rank_num = table_json["compare"]["rank"] if "rank" in table_json["compare"].keys() else 1
        rank_metric = table_json["compare"]["metric"] if "metric" in table_json["compare"].keys() else "max"
        palette = sns.color_palette(palette_name)

    with open(args.target, "w") as f:
        f.write("\\begin{center}\n")
        if rank_num > 0:
            # write color def 
            for i in range(rank_num):
                color = palette[i]
                color_str = "\\definecolor{color" + str(i) + "}{rgb}{" + f"{color[0]:.2f}, {color[1]:.2f},{color[2]:.2f}" + "}\n"
                f.write(color_str)

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
        data = table_json["data"]
        marked_data = data 
        if rank_num > 0:
            marks = []
            for j in range(len(table_json["cols"])):
                marks.append([])
            for i, row in enumerate(data):
                for j in range(len(row)):
                    marks[j].append(
                        {
                            "value": row[j],
                            "row": i
                        })
            # sort accordint to value
            for j in range(len(marks)):
                marks[j].sort(key=lambda x: x["value"], reverse=rank_metric == "max")

            # write back to marked_data
            for j in range(len(marks)):
                for i, mark in enumerate(marks[j]):
                    marked_data[mark["row"]][j] = (i, mark["value"])

            # write to tex
            for i, row in enumerate(marked_data):
                if len_rows > 0:
                    row_title = latex_content(str(table_json["rows"][i]))
                    f.write(row_title + " & ")
                for item in row[:-1]:
                    if isinstance(item, tuple):
                        if (item[0] < rank_num):
                            color_str = "color" + str(item[0])
                            f.write("\\cellcolor{" + color_str + "}" + latex_content(str(item[1])) + " & ")
                        else:
                            f.write(latex_content(str(item[1])) + " & ")
                    else:
                        f.write(latex_content(str(item)) + " & ")
                if isinstance(row[-1], tuple):
                    item = row[-1]
                    if (item[0] < rank_num):
                        color_str = "color" + str(item[0])
                        f.write("\\cellcolor{" + color_str + "}" + latex_content(str(item[1])))
                    else:
                        f.write(latex_content(str(item[1])))
                else:
                    f.write(latex_content(str(row[-1])))
                f.write("\\\\ \\hline\n")

        else:
            for idx, row in enumerate(table_json["data"]):
                if len_rows > 0:
                    content = latex_content(str(table_json["rows"][idx]))
                    f.write(content + " & ")
                for item in row[:-1]:
                    f.write(latex_content(str(item)))
                f.write(latex_content(str(row[-1])))
                f.write("\\\\ \\hline\n")


        f.write("\\end{tabular}\n")
        f.write("\\end{center}\n")