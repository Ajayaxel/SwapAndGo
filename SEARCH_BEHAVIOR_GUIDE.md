# Station Search - User Behavior Guide

## How the Search Works

### 📱 Step-by-Step User Flow

#### **Step 1: Initial State (Page Load)**
```
┌─────────────────────────────────────┐
│  🔍 Find swap stations              │
└─────────────────────────────────────┘

[MAP VIEW - No suggestions visible]
```
✅ **Clean UI** - No dropdown suggestions shown
✅ **Stations loaded** - API fetched 100 stations in background
❌ **No suggestions** - User hasn't tapped search yet

---

#### **Step 2: User Taps Search Bar**
```
┌─────────────────────────────────────┐
│  🔍 Find swap stations              │
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│ 🔋 Dubai Marina Station             │
│    123 Marina Walk, Dubai           │
│    📍 2.5 km  🔋 15/20 slots        │
├─────────────────────────────────────┤
│ 🔋 Business Bay Station             │
│    45 Bay Avenue, Dubai             │
│    📍 3.2 km  🔋 35/40 slots        │
├─────────────────────────────────────┤
│ 🔋 Palm Jumeirah Station            │
│    1 Crescent Road, Dubai           │
│    📍 4.1 km  🔋 18/20 slots        │
└─────────────────────────────────────┘
```
✅ **Top 10 nearest stations appear**
✅ **Sorted by distance** - Closest first
✅ **Real-time distance calculation**

---

#### **Step 3: User Types to Search**
```
┌─────────────────────────────────────┐
│  🔍 marina                     X    │
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│ 🔋 Dubai Marina Station             │
│    123 Marina Walk, Dubai           │
│    📍 2.5 km  🔋 15/20 slots        │
└─────────────────────────────────────┘
```
✅ **Filtered results** - Only matching stations
✅ **Still sorted by distance**
✅ **Clear button (X) appears**

---

#### **Step 4: User Selects Station**
```
┌─────────────────────────────────────┐
│  🔍 Dubai Marina Station            │
└─────────────────────────────────────┘

[MAP VIEW - Route displayed to station]
[BOTTOM SHEET - Station details shown]
```
✅ **Suggestions hidden**
✅ **Search filled with station name**
✅ **Route displayed on map**
✅ **Bottom sheet appears**

---

#### **Step 5: User Clicks Clear (X)**
```
┌─────────────────────────────────────┐
│  🔍 Find swap stations              │
└─────────────────────────────────────┘

[MAP VIEW - Previous route may still show]
```
✅ **Search text cleared**
✅ **Suggestions hidden**
✅ **Ready for new search**

---

## 🎯 Key Behaviors

### ✅ DO Show Suggestions When:
- User taps/clicks the search bar
- User types in the search field (filtered results)

### ❌ DON'T Show Suggestions When:
- Page first loads
- User hasn't interacted with search
- User clicked clear button
- User selected a station

### 🔄 Suggestions Update When:
- User types (filters by query)
- Stations list changes from API
- User's location updates (re-calculates distances)

### 📏 Distance Calculation:
- Uses **Haversine formula** for accurate distance
- Based on user's **current location**
- Updates when location changes
- Displayed in **kilometers (km)**

---

## 🎨 Visual Indicators

### Station Availability Colors:
- 🟢 **Green Icon** - Available slots (> 0)
- 🔴 **Red Icon** - Full / No slots (0)

### Station Information Display:
```
🔋 [Station Name]
   [Full Address], [City]
   📍 [Distance] km  🔋 [Available]/[Total] slots
```

---

## 📝 Example User Journey

1. **User opens home page**
   - Search bar is empty
   - No suggestions visible
   - Map shows all station markers

2. **User taps search bar**
   - 10 nearest stations appear instantly
   - Sorted from closest to farthest
   - Each shows distance and availability

3. **User types "marina"**
   - List filters to matching stations
   - Still sorted by distance
   - Clear (X) button appears

4. **User selects "Dubai Marina Station"**
   - Suggestions disappear
   - Station name fills search bar
   - Map shows route
   - Bottom sheet appears with details

5. **User books or navigates**
   - Can proceed to scan/book
   - Can start navigation
   - Can search for another station

---

## 🔍 Search Matching

The search filters stations by:
- ✅ Station **name**
- ✅ Station **address**
- ✅ Station **city**
- ✅ Station **code**

All searches are **case-insensitive** and use **contains** matching.

### Examples:
- `"dubai"` → Matches all Dubai stations
- `"marina"` → Matches Dubai Marina Station
- `"DB001"` → Matches station with code DB001
- `"bay"` → Matches Business Bay Station

---

## 💡 Pro Tips

1. **Quick Access**: Just tap the search bar to see nearest stations
2. **Smart Filtering**: Type any part of name, address, city, or code
3. **Distance Matters**: Results always show nearest first
4. **Check Availability**: Green icons mean slots available
5. **Clear & Retry**: Use (X) button to start fresh search

---

## ⚠️ Edge Cases Handled

- ✅ No stations available → Shows empty state
- ✅ No location permission → Stations shown but no distance
- ✅ API loading → Waits for stations to load
- ✅ No matching results → Shows "No stations found"
- ✅ Location updates → Recalculates distances automatically

---

This search experience provides a **clean, focused, and location-aware** way to find the nearest charging stations!


