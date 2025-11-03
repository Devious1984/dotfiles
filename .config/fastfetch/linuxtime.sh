#!/usr/bin/env bash

# ---- start and now dates ---------------------------------------------------
start_date="2025-09-13"
now_date=$(date +%Y-%m-%d)

# ---- functions for GNU/BSD compatibility -----------------------------------
get_epoch() {
  if date -d "$1" +%s >/dev/null 2>&1; then
    date -d "$1" +%s
  else
    date -jf %Y-%m-%d "$1" +%s
  fi
}

add_years() {
  if date -d "$1 + $2 years" +%Y-%m-%d >/dev/null 2>&1; then
    date -d "$1 + $2 years" +%Y-%m-%d
  else
    date -jf %Y-%m-%d "$1" -v +"$2"y +%Y-%m-%d
  fi
}

add_months() {
  if date -d "$1 + $2 months" +%Y-%m-%d >/dev/null 2>&1; then
    date -d "$1 + $2 months" +%Y-%m-%d
  else
    date -jf %Y-%m-%d "$1" -v +"$2"m +%Y-%m-%d
  fi
}

# ---- epochs ----------------------------------------------------------------
start_epoch=$(get_epoch "$start_date")
now_epoch=$(get_epoch "$now_date")

# ---- handle future dates (swap if now < start) -----------------------------
direction="ago"
if [ "$now_epoch" -lt "$start_epoch" ]; then
  temp_date="$start_date"
  start_date="$now_date"
  now_date="$temp_date"

  temp_epoch="$start_epoch"
  start_epoch="$now_epoch"
  now_epoch="$temp_epoch"

  direction="in"
fi

# ---- calculate years -------------------------------------------------------
years=0
temp_date="$start_date"
while [ $(get_epoch $(add_years "$temp_date" 1)) -le "$now_epoch" ]; do
  years=$((years + 1))
  temp_date=$(add_years "$temp_date" 1)
done
[ "$years" -eq 1 ] && ys=year || ys=years

# ---- calculate months ------------------------------------------------------
months=0
while [ $(get_epoch $(add_months "$temp_date" 1)) -le "$now_epoch" ]; do
  months=$((months + 1))
  temp_date=$(add_months "$temp_date" 1)
done
[ "$months" -eq 1 ] && ms=month || ms=months

# ---- calculate days --------------------------------------------------------
days=$(((now_epoch - $(get_epoch "$temp_date")) / 86400))
[ "$days" -eq 1 ] && ds=day || ds=days

# ---- build output string, skipping zeros -----------------------------------
out=""
[ "$years" -gt 0 ] && out+="$years $ys "
[ "$months" -gt 0 ] && out+="$months $ms "
[ "$days" -gt 0 ] && out+="$days $ds "

if [ -z "$out" ]; then
  out="today"
  direction=""
else
  out="${out% }" # remove trailing space
fi

# ---- output ----------------------------------------------------------------
printf '%s%s\n' "$out" "${direction:+ $direction}"
