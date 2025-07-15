Data source: https://www.kaggle.com/code/heeraldedhia/exploratory-data-analysis-in-r/input

**Excel Bike Purchase Data Analysis Project**

🧠 **Project Objective**
The goal of this project was to analyze customer data to uncover trends related to bike purchases. The dataset includes demographic, socioeconomic, and lifestyle information, allowing us to explore which groups are more likely to purchase bikes.

🧰 **Tools & Features Used**
Excel Functions:

IF and IFS statements to classify and categorize values

TRIM, PROPER, and TEXT functions for formatting

SEARCH/FIND with SUBSTITUTE to clean or parse text

Find & Replace (Ctrl + H):

Replaced ambiguous abbreviations:

“S” → “Single”

“M” → “Married”

Ensured consistency in values across fields like “Gender”, “Region”, etc.

**Data Cleaning:**

Standardized currency and date formats (e.g., Income to US dollar format: $XX,XXX)

Removed trailing spaces and corrected case formatting (using =TRIM() function)

**Pivot Tables & Charts:**

Created interactive pivot tables to break down bike purchases by: Marital Status, Income Range, Commute, Distance, Education & Occupation, Region

Visualized findings using bar charts, line charts, and stacked columns

**Dashboard:**

Compiled key visualizations into a single Excel dashboard

Added Slicers for: Region, Education, Marital Status, Number of Cars Owned

Slicers allow for dynamic filtering, making insights customizable and interactive

🔍 **Key Insights Uncovered**

Households that have purchased a bike and have 0 cars have a larger portion of their bike purchases for either 0-1 mile commutes or 2-5 mile commutes

Households that have purchased a bike and have 1 cars have a larger portion of their bike purchases for either 0-1 mile commutes or 2-5 mile commutes

Households that have purchased a bike and have 2 cars have a larger portion of their bike purchases for either 2-5 mile commutes or 5-10 mile commutes

Households that have purchased a bike and have 3 cars have a larger proportion of their bike purchases for either 0-1 mile commutes or 10+ mile commutes

Households that have purchased a bike and have 4 cars have a larger portion of their bike purchases for either 5-10 mile commutes or 10+ mile commutes

These previous distance findings in combination with the trend that households that purchased a bike and have more cars have a higher average income, we can conclude that these households
may be purchasing bikes for recreation (mountainbiking, cycling, exercise, leisure) rather than for commuting shorter distances to say work.

Households that had 0-1 cars were more likely to buy a bike than households with 2-4 cars.

The Pacific region showed much higher purchase rates compared to the others.

✅ **Final Deliverables**

Cleaned Excel workbook with raw data and formulas

Pivot tables with dynamic summaries

Interactive dashboard with slicers

README file for documentation (this!)
