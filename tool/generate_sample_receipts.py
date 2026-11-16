#!/usr/bin/env python3
"""Generates fake demo receipts into assets/sample_receipts/ (requires Pillow).

Every image is marked "SAMPLE - demo data": they exist only to try the OCR and
the parser, and must not be passed off as real receipts.
Usage: python3 tool/generate_sample_receipts.py
"""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

OUT = Path(__file__).resolve().parent.parent / "assets" / "sample_receipts"
FONT = "/System/Library/Fonts/Supplemental/Courier New.ttf"
FONT_BOLD = "/System/Library/Fonts/Supplemental/Courier New Bold.ttf"
WIDTH = 720
MARGIN = 40

RECEIPTS = {
    "cafe": {
        "title": "HIGHLANDS COFFEE",
        "sub": ["123 Nguyen Hue, Quan 1", "Tp. Ho Chi Minh"],
        "meta": ["Số HĐ: 00012345", "Ngày: 12/03/2025 14:35"],
        "items": [("Cà phê sữa đá x2", "58.000"), ("Bánh mì que", "25.000"), ("Trà đào", "45.000")],
        "extra": [("Tạm tính", "128.000"), ("VAT 8%", "10.240")],
        "total": ("Tổng cộng", "138.240"),
    },
    "supermarket": {
        "title": "WINMART SIEU THI",
        "sub": ["45 Le Loi, Quan 1"],
        "meta": ["Bill No: SM-778812", "Ngày: 03/04/2025 18:20"],
        "items": [("Sữa tươi 1L", "32.000"), ("Gạo ST25 5kg", "185.000"), ("Trứng gà 10 quả", "38.000"), ("Rau cải", "15.000")],
        "extra": [("Tạm tính", "270.000")],
        "total": ("Tổng tiền", "270.000"),
    },
    "restaurant": {
        "title": "SAIGON KITCHEN",
        "sub": ["88 Dong Khoi, District 1"],
        "meta": ["Invoice No: INV-20931", "Date: 21/05/2025 19:45"],
        "items": [("Pho bo", "75.000"), ("Goi cuon x2", "60.000"), ("Iced tea", "20.000")],
        "extra": [("Subtotal", "155.000"), ("Service 5%", "7.750")],
        "total": ("Total", "162.750"),
    },
    "bookstore": {
        "title": "NHÀ SÁCH FAHASA",
        "sub": ["60 Nguyễn Thị Minh Khai"],
        "meta": ["Số HĐ: FH-5521", "Ngày: 09/09/2025 10:05"],
        "items": [("Sách Lập trình Dart", "189.000"), ("Vở kẻ ngang x5", "45.000"), ("Bút bi xanh", "12.000")],
        "extra": [("Tạm tính", "246.000")],
        "total": ("Thành tiền", "246.000"),
    },
}


def draw_receipt(name: str, data: dict) -> None:
    font = ImageFont.truetype(FONT, 28)
    bold = ImageFont.truetype(FONT_BOLD, 28)
    big = ImageFont.truetype(FONT_BOLD, 36)
    small = ImageFont.truetype(FONT, 22)

    lines = 4 + len(data["sub"]) + len(data["meta"]) + len(data["items"]) + len(data["extra"]) + 4
    height = 120 + lines * 46 + 120
    img = Image.new("RGB", (WIDTH, height), "white")
    d = ImageDraw.Draw(img)
    y = 40

    def centered(text, fnt):
        nonlocal y
        w = d.textlength(text, font=fnt)
        d.text(((WIDTH - w) / 2, y), text, font=fnt, fill="black")
        y += 46

    def row(label, value, fnt):
        nonlocal y
        d.text((MARGIN, y), label, font=fnt, fill="black")
        d.text((WIDTH - MARGIN - d.textlength(value, font=fnt), y), value, font=fnt, fill="black")
        y += 46

    def rule():
        nonlocal y
        d.line([(MARGIN, y + 10), (WIDTH - MARGIN, y + 10)], fill="black", width=2)
        y += 30

    centered(data["title"], big)
    for s in data["sub"]:
        centered(s, font)
    rule()
    for m in data["meta"]:
        d.text((MARGIN, y), m, font=font, fill="black")
        y += 46
    rule()
    for label, value in data["items"]:
        row(label, value, font)
    rule()
    for label, value in data["extra"]:
        row(label, value, font)
    row(*data["total"], bold)
    rule()
    centered("Cảm ơn quý khách / Thank you", font)
    centered("SAMPLE - demo data", small)

    img = img.crop((0, 0, WIDTH, y + 30))
    OUT.mkdir(parents=True, exist_ok=True)
    img.save(OUT / f"{name}.jpg", quality=92)


for key, value in RECEIPTS.items():
    draw_receipt(key, value)
print(f"Wrote {len(RECEIPTS)} receipts to {OUT}")
