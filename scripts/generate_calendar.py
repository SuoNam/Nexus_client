"""Build the bundled 2026 public holiday calendar with holidays==0.105."""
import json
from datetime import date, timedelta
from pathlib import Path
import holidays

assert holidays.__version__ == "0.105", "Install holidays==0.105 for reproducible data"
calendars = {}
for country, subdivisions in holidays.list_supported_countries(include_aliases=False).items():
    for subdivision in [None, *subdivisions]:
        calendar = holidays.country_holidays(country, subdiv=subdivision, years=2026, language="zh_CN")
        if not calendar.start_year <= 2026 <= calendar.end_year:
            continue
        days = {}
        day = date(2026, 1, 1)
        while day.year == 2026:
            if day in calendar.weekend_workdays:
                days[day.isoformat()] = ["makeup", ""]
            elif day in calendar:
                days[day.isoformat()] = ["holiday", calendar[day]]
            elif calendar.is_weekend(day):
                days[day.isoformat()] = ["weekend", ""]
            day += timedelta(days=1)
        calendars[country + ("/" + subdivision if subdivision else "")] = days
target = Path(__file__).resolve().parents[1] / "data" / "calendar-2026.json"
target.parent.mkdir(exist_ok=True)
target.write_text(json.dumps({"year": 2026, "source": "holidays 0.105", "calendars": calendars},
                             ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
print(f"Generated {len(calendars)} calendars: {target.stat().st_size} bytes")
