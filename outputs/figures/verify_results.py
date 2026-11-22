"""Verify descriptive results and independently score the exported test predictions."""

import argparse
from pathlib import Path

import numpy as np
import pandas as pd


def verify_sales(csv_path, reports):
    sales = pd.read_csv(csv_path)
    assert sales.shape == (16719, 16)
    years = sales.groupby("Year_of_Release")["Global_Sales"].sum()
    publishers = sales.groupby("Publisher")["Global_Sales"].sum()
    genres = sales.groupby("Genre")[["Global_Sales", "JP_Sales"]].sum()
    has_name = sales["Name"].notna() & sales["Name"].str.strip().ne("")
    repeated = has_name & sales["Name"].duplicated(keep=False)
    single = sales.loc[~repeated, "Global_Sales"].sum()
    multi = sales.loc[repeated, "Global_Sales"].sum()
    rows = [
        ("Dataset rows", len(sales), "rows"),
        ("Dataset columns", sales.shape[1], "columns"),
        ("Peak release year", int(years.idxmax()), "year"),
        ("Peak release year sales", years.max(), "million units"),
        ("Top publisher", publishers.idxmax(), "publisher"),
        ("Nintendo sales", publishers["Nintendo"], "million units"),
        ("Electronic Arts sales", publishers["Electronic Arts"], "million units"),
        ("Activision sales", publishers["Activision"], "million units"),
        ("Nintendo to Activision sales ratio", publishers["Nintendo"] / publishers["Activision"], "ratio"),
        ("Leading global genre", genres["Global_Sales"].idxmax(), "genre"),
        ("Leading global genre sales", genres["Global_Sales"].max(), "million units"),
        ("Leading Japanese genre", genres["JP_Sales"].idxmax(), "genre"),
        ("Leading Japanese genre sales", genres["JP_Sales"].max(), "million units"),
        ("Repeated-title sales", multi, "million units"),
        ("Other rows' sales", single, "million units"),
        ("Repeated-title total sales difference", (multi / single - 1) * 100, "percent"),
    ]
    result = pd.DataFrame(rows, columns=["Check", "Value", "Unit"])
    result.to_csv(reports / "descriptive_checks.csv", index=False)
    return sales, result


def verify_predictions(sales, reports):
    predictions = pd.read_csv(reports / "heldout_predictions.csv")
    models = pd.read_csv(reports / "model_comparison.csv").set_index("Model")
    actual = predictions["Actual_Global_Sales"].to_numpy()
    assert len(predictions) == 1500
    assert predictions["CSV_row_index"].is_unique
    np.testing.assert_array_equal(actual, sales.loc[predictions["CSV_row_index"], "Global_Sales"])
    total_sum_squares = np.square(actual - actual.mean()).sum()
    rows = []
    for name in [*models.index, "Training_mean_baseline"]:
        errors = predictions[name].to_numpy() - actual
        squared_errors = np.square(errors)
        metrics = np.array([
            np.sqrt(squared_errors.mean()),
            np.abs(errors).mean(),
            1 - squared_errors.sum() / total_sum_squares,
        ])
        assert np.isfinite(metrics).all()
        if name in models.index:
            np.testing.assert_allclose(
                metrics,
                models.loc[name, ["Test_RMSE", "Test_MAE", "Test_R2"]].to_numpy(),
                rtol=1e-7,
                atol=1e-10,
            )
        rows.append([name, *metrics])
    result = pd.DataFrame(rows, columns=["Model", "Test_RMSE", "Test_MAE", "Test_R2"])
    result.to_csv(reports / "verified_holdout_metrics.csv", index=False)
    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("dataset", type=Path)
    parser.add_argument("--reports", type=Path, default=Path(__file__).parent / "reports")
    parser.add_argument("--sales-only", action="store_true")
    args = parser.parse_args()
    data, descriptive = verify_sales(args.dataset, args.reports)
    print(descriptive.to_string(index=False))
    if not args.sales_only:
        print(verify_predictions(data, args.reports).to_string(index=False))
