from reportlab.lib.pagesizes import letter
from reportlab.lib.units import inch
from reportlab.lib import colors
from reportlab.platypus import (SimpleDocTemplate, Paragraph, Spacer, PageBreak,
                                 Table, TableStyle, Image, HRFlowable)
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_CENTER, TA_LEFT

NAVY = colors.HexColor('#1f3a5f')
TEAL = colors.HexColor('#2a9d8f')
GOLD = colors.HexColor('#e9c46a')
RED = colors.HexColor('#e76f51')
LIGHTGREY = colors.HexColor('#f4f5f7')
DARKGREY = colors.HexColor('#4a4a4a')

styles = getSampleStyleSheet()
styles.add(ParagraphStyle('CoverTitle', fontSize=28, leading=34, textColor=NAVY,
                           fontName='Helvetica-Bold', alignment=TA_CENTER, spaceAfter=10))
styles.add(ParagraphStyle('CoverSub', fontSize=14, leading=18, textColor=DARKGREY,
                           alignment=TA_CENTER, spaceAfter=6))
styles.add(ParagraphStyle('H1', fontSize=18, leading=22, textColor=NAVY,
                           fontName='Helvetica-Bold', spaceBefore=6, spaceAfter=10))
styles.add(ParagraphStyle('H2', fontSize=13, leading=16, textColor=NAVY,
                           fontName='Helvetica-Bold', spaceBefore=14, spaceAfter=6))
styles.add(ParagraphStyle('Body', fontSize=10, leading=14.5, textColor=DARKGREY,
                           alignment=TA_LEFT, spaceAfter=6))
styles.add(ParagraphStyle('Small', fontSize=8.5, leading=11, textColor=colors.grey))
styles.add(ParagraphStyle('Finding', fontSize=10.5, leading=14, textColor=colors.HexColor('#1f1f1f'),
                           fontName='Helvetica-Bold', spaceBefore=8, spaceAfter=2))
styles.add(ParagraphStyle('Rec', fontSize=10, leading=14, textColor=DARKGREY, spaceAfter=4))

CH = '/home/claude/charts/'
elements = []

# ---------------- COVER PAGE ----------------
elements.append(Spacer(1, 1.6*inch))
elements.append(Paragraph("Sales Performance Dashboard", styles['CoverTitle']))
elements.append(Paragraph("Superstore Business Analysis & Recommendations Report", styles['CoverSub']))
elements.append(Spacer(1, 0.3*inch))
elements.append(HRFlowable(width="40%", thickness=1.5, color=GOLD, hAlign='CENTER'))
elements.append(Spacer(1, 0.5*inch))
elements.append(Paragraph("Data Period: 2014 – 2017 &nbsp;|&nbsp; Records Analyzed: 9,994 order lines", styles['CoverSub']))
elements.append(Paragraph("Prepared using SQL data pipeline (Phases 3–11) &amp; Power BI dashboard design", styles['CoverSub']))
elements.append(Spacer(1, 2.2*inch))
elements.append(Paragraph("Confidential — For Internal Business Use", styles['Small']))
elements.append(PageBreak())

# ---------------- EXECUTIVE OVERVIEW ----------------
elements.append(Paragraph("1. Executive Overview", styles['H1']))
elements.append(Paragraph(
    "This report summarizes performance across five years of Superstore transaction data, "
    "covering sales, profitability, products, customers, geography, discounting, and shipping. "
    "All figures are computed directly from the cleaned dataset (superstore_final) produced by the "
    "SQL pipeline in this project.", styles['Body']))

kpi_data = [
    ['Metric', 'Value'],
    ['Total Sales', '$2,297,200.86'],
    ['Total Profit', '$286,397.02'],
    ['Profit Margin', '12.47%'],
    ['Total Orders', '5,009'],
    ['Total Customers', '793'],
    ['Total Units Sold', '37,873'],
    ['Average Order Value', '$458.61'],
    ['Average Discount', '15.62%'],
]
t = Table(kpi_data, colWidths=[2.6*inch, 2.6*inch])
t.setStyle(TableStyle([
    ('BACKGROUND', (0,0), (-1,0), NAVY),
    ('TEXTCOLOR', (0,0), (-1,0), colors.white),
    ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
    ('FONTNAME', (0,1), (-1,-1), 'Helvetica'),
    ('FONTSIZE', (0,0), (-1,-1), 10),
    ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, LIGHTGREY]),
    ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor('#dddddd')),
    ('TOPPADDING', (0,0), (-1,-1), 6),
    ('BOTTOMPADDING', (0,0), (-1,-1), 6),
    ('ALIGN', (1,0), (1,-1), 'RIGHT'),
]))
elements.append(t)
elements.append(Spacer(1, 0.2*inch))
elements.append(Paragraph(
    "The business is solidly profitable at a 12.47% margin, but this masks wide variation across "
    "categories, geographies, and discount levels explored in the sections below.", styles['Body']))
elements.append(PageBreak())

# ---------------- SALES ANALYSIS ----------------
elements.append(Paragraph("2. Sales Analysis", styles['H1']))
elements.append(Image(CH+'monthly_sales.png', width=6.3*inch, height=2.8*inch))
elements.append(Spacer(1, 0.1*inch))
elements.append(Paragraph(
    "<b>Best month:</b> November 2017, with $118,447.83 in sales — driven by holiday-season demand. "
    "<b>Worst month:</b> February 2014, with just $4,519.89 in sales, the weakest point in the entire dataset.",
    styles['Body']))
elements.append(Image(CH+'yearly_growth.png', width=5.2*inch, height=3.0*inch))
elements.append(Paragraph(
    "<b>Is revenue growing?</b> Yes, overall. Sales dipped 2.83% in 2015 but rebounded strongly: "
    "+29.47% in 2016 and +20.36% in 2017, closing the period at $733,215 — the highest annual total "
    "on record.", styles['Body']))
elements.append(PageBreak())

# ---------------- PRODUCT ANALYSIS ----------------
elements.append(Paragraph("3. Product Analysis", styles['H1']))
elements.append(Image(CH+'category_sales_profit.png', width=5.6*inch, height=3.4*inch))
elements.append(Paragraph(
    "Technology is the strongest category on every dimension: $836,154 in sales and $145,455 in profit "
    "(17.4% margin). Office Supplies is close behind on margin (17.0%). Furniture is the clear laggard "
    "— $741,999 in sales but only $18,451 in profit, a 2.49% margin.", styles['Body']))
elements.append(Image(CH+'subcategory_profit.png', width=5.6*inch, height=4.4*inch))
elements.append(Paragraph(
    "<b>Loss-making sub-categories:</b> Tables (-$17,725) and Bookcases (-$3,473) are the only two "
    "sub-categories operating at a net loss. <b>Best-selling product:</b> Canon imageCLASS 2200 Advanced "
    "Copier ($61,600 sales, $25,200 profit — also the single most profitable product). <b>Biggest loss-maker:</b> "
    "Cubify CubeX 3D Printer (Double Head), at -$8,880.", styles['Body']))
elements.append(PageBreak())

# ---------------- CUSTOMER ANALYSIS ----------------
elements.append(Paragraph("4. Customer Analysis", styles['H1']))
elements.append(Image(CH+'top_customers.png', width=5.6*inch, height=3.6*inch))
elements.append(Paragraph(
    "<b>Top customer:</b> Sean Miller, with $25,043 in lifetime sales. <b>Average customer spending</b> "
    "across the full period is $2,896.85. <b>Repeat purchase rate</b> is exceptionally strong: 781 of 793 "
    "customers (98.5%) placed more than one order. <b>Most valuable segment:</b> Consumer — 409 customers "
    "generating $1.16M in sales and $134,119 in profit, ahead of Corporate ($706K sales) and Home Office "
    "($430K sales).", styles['Body']))
elements.append(PageBreak())

# ---------------- GEOGRAPHIC ANALYSIS ----------------
elements.append(Paragraph("5. Geographic Analysis", styles['H1']))
elements.append(Image(CH+'region.png', width=5.6*inch, height=3.2*inch))
elements.append(Paragraph(
    "<b>Best-performing region:</b> West, with $725,458 in sales and $108,418 in profit — the top region "
    "on both metrics. <b>Best-performing state:</b> California ($457,688 in sales, ~20% of company total), "
    "followed by New York ($310,876). <b>Worst-performing city:</b> Philadelphia, PA, which posts healthy "
    "sales but a net loss of -$13,838 — the largest city-level loss in the dataset, driven by heavy "
    "discounting.", styles['Body']))
elements.append(PageBreak())

# ---------------- DISCOUNT ANALYSIS ----------------
elements.append(Paragraph("6. Discount Analysis", styles['H1']))
elements.append(Image(CH+'discount_profit.png', width=5.6*inch, height=3.2*inch))
elements.append(Paragraph(
    "<b>Does discount increase sales?</b> Not meaningfully — sales volume is fairly evenly spread across "
    "discount bands, and roughly half of all sales dollars already occur at 0% discount, indicating deep "
    "discounts are not the primary volume driver. <b>Does discount reduce profit?</b> Yes, sharply. Profit "
    "turns negative once discounts exceed ~20%; line items discounted above 20% collectively lose "
    "$135,376 across 1,393 transactions.", styles['Body']))
elements.append(Spacer(1, 0.15*inch))
elements.append(Image(CH+'ship_mode.png', width=5.2*inch, height=3.0*inch))
elements.append(Paragraph(
    "<b>Most profitable shipping mode:</b> First Class, at a 13.93% margin — ahead of Second Class (12.51%), "
    "Same Day (12.38%), and Standard Class (12.08%). Standard Class carries 68% of sales volume, so it "
    "generates the most total profit dollars, but at the lowest margin of any mode.", styles['Body']))
elements.append(PageBreak())

# ---------------- RECOMMENDATIONS ----------------
elements.append(Paragraph("7. Business Recommendations", styles['H1']))
elements.append(Paragraph(
    "The five findings below represent the highest-impact opportunities identified in this analysis, "
    "each paired with a concrete recommendation and its expected business impact.", styles['Body']))

recs = [
    ("Finding 1 — Furniture has strong sales but poor profit",
     "$741,999 in sales but only a 2.49% margin ($18,451 profit); Tables and Bookcases are net-loss sub-categories.",
     "Review Furniture pricing and supplier costs, and restrict discounting on Tables and Bookcases.",
     "Could recover a meaningful share of the ~$21K currently lost across these two sub-categories."),
    ("Finding 2 — California generates the highest revenue",
     "California alone contributes $457,688 in sales, about 20% of total company revenue.",
     "Prioritize inventory allocation and marketing spend toward California and the wider West region; "
     "evaluate a West-region fulfillment hub.",
     "Supports continued growth in the company's single largest market."),
    ("Finding 3 — Large discounts reduce profit",
     "Discounts above 20% are collectively unprofitable: -$135,376 across 1,393 line items.",
     "Cap standard discounts at 20%, with manager approval required for exceptions.",
     "Directly protects up to $135K in profit currently given away on deep-discount transactions."),
    ("Finding 4 — Technology has the highest margins",
     "Technology posts a 17.4% margin, the best of the three categories, plus the highest total profit ($145,455).",
     "Increase advertising and promotional investment behind Technology, especially Copiers and Accessories.",
     "Compounds returns in the company's highest-ROI category."),
    ("Finding 5 — Standard Class shipping runs the thinnest margin",
     "Standard Class carries 68% of sales volume at just a 12.08% margin, the lowest of all four ship modes.",
     "Audit the discount and cost mix on Standard Class orders; test promoting First/Second Class for "
     "higher-margin SKUs.",
     "Could close the ~1.9 percentage-point margin gap versus First Class."),
]

for i, (finding_title, finding, rec, impact) in enumerate(recs, 1):
    elements.append(Paragraph(finding_title, styles['Finding']))
    elements.append(Paragraph(f"<b>Finding:</b> {finding}", styles['Rec']))
    elements.append(Paragraph(f"<b>Recommendation:</b> {rec}", styles['Rec']))
    elements.append(Paragraph(f"<b>Expected Impact:</b> {impact}", styles['Rec']))
    if i < len(recs):
        elements.append(HRFlowable(width="100%", thickness=0.5, color=colors.HexColor('#dddddd')))

elements.append(Spacer(1, 0.25*inch))
elements.append(Paragraph("Summary Table", styles['H2']))
summary_data = [
    ['#', 'Finding', 'Recommendation', 'Expected Impact'],
    ['1', 'Furniture: 2.49% margin\ndespite $742K sales', 'Review pricing &\nlimit discounting', 'Recover ~$21K in\nTables/Bookcases losses'],
    ['2', 'California: top revenue\nstate (~20% of total)', 'Prioritize CA inventory\n& fulfillment', 'Sustain growth in\ntop market'],
    ['3', 'Discounts >20% lose\n$135K overall', 'Cap discounts\nat 20%', 'Protect up to\n$135K profit'],
    ['4', 'Technology: best margin\n(17.4%) & profit', 'Increase Technology\nad spend', 'Compound highest-\nROI category'],
    ['5', 'Standard Class: lowest\nmargin ship mode', 'Audit Standard Class\ndiscount mix', 'Close ~1.9pp\nmargin gap'],
]
t2 = Table(summary_data, colWidths=[0.3*inch, 1.9*inch, 1.9*inch, 1.8*inch])
t2.setStyle(TableStyle([
    ('BACKGROUND', (0,0), (-1,0), NAVY),
    ('TEXTCOLOR', (0,0), (-1,0), colors.white),
    ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
    ('FONTNAME', (0,1), (-1,-1), 'Helvetica'),
    ('FONTSIZE', (0,0), (-1,-1), 8.5),
    ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, LIGHTGREY]),
    ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor('#dddddd')),
    ('VALIGN', (0,0), (-1,-1), 'TOP'),
    ('TOPPADDING', (0,0), (-1,-1), 5),
    ('BOTTOMPADDING', (0,0), (-1,-1), 5),
]))
elements.append(t2)

doc = SimpleDocTemplate('/home/claude/sales-performance-dashboard/report/Sales Performance Dashboard.pdf',
                         pagesize=letter,
                         topMargin=0.6*inch, bottomMargin=0.6*inch,
                         leftMargin=0.7*inch, rightMargin=0.7*inch,
                         title="Sales Performance Dashboard Report")
doc.build(elements)
print("PDF built.")
