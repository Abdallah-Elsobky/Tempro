# Weather API Documentation

## Base URL

```http
https://api.weatherapi.com/v1
```

## Authentication

All requests require an API key:

```http
GET /current.json?key=YOUR_API_KEY&q=Cairo
```

---

# 1. Current Weather

Get current weather conditions for a location.

### Endpoint

```http
GET /current.json
```

### Parameters

| Name | Required | Description                                            |
| ---- | -------- | ------------------------------------------------------ |
| q    | ✅        | City name, ZIP code, IP address, or latitude/longitude |
| lang | ❌        | Response language                                      |

### Example

```http
/current.json?q=Cairo
```

### Returns

* Current temperature
* Weather condition
* Humidity
* Wind speed
* UV index
* Air quality

---

# 2. Forecast Weather

Get weather forecast for upcoming days.

### Endpoint

```http
GET /forecast.json
```

### Parameters

| Name   | Required | Description                       |
| ------ | -------- | --------------------------------- |
| q      | ✅        | Location                          |
| days   | ✅        | Number of forecast days (1-14)    |
| alerts | ❌        | Include weather alerts (yes/no)   |
| aqi    | ❌        | Include air quality data (yes/no) |
| lang   | ❌        | Response language                 |

### Example

```http
/forecast.json?q=Cairo&days=7
```

### Returns

* Current weather
* Daily forecast
* Hourly forecast
* Astronomy data
* Weather alerts

---

# 3. Future Weather

Get future weather predictions beyond the normal forecast range.

### Endpoint

```http
GET /future.json
```

### Parameters

| Name | Required | Description                     |
| ---- | -------- | ------------------------------- |
| q    | ✅        | Location                        |
| dt   | ✅        | Future date (14-300 days ahead) |

### Example

```http
/ future.json?q=Cairo&dt=2027-01-01
```

### Returns

* Predicted weather for a future date
* 3-hour forecast intervals

---

# 4. Historical Weather

Retrieve weather data from the past.

### Endpoint

```http
GET /history.json
```

### Parameters

| Name   | Required | Description                  |
| ------ | -------- | ---------------------------- |
| q      | ✅        | Location                     |
| dt     | ✅        | Start date                   |
| end_dt | ❌        | End date (max 30 days range) |

### Example

```http
/ history.json?q=Cairo&dt=2026-01-01
```

### Returns

* Historical temperatures
* Humidity
* Wind data
* Hourly weather records

---

# 5. Marine Weather

Marine and sailing weather forecasts.

### Endpoint

```http
GET /marine.json
```

### Parameters

| Name | Required | Description                       |
| ---- | -------- | --------------------------------- |
| q    | ✅        | Latitude,Longitude (sea location) |
| days | ✅        | Forecast days (1-7)               |

### Example

```http
/ marine.json?q=31.2001,29.9187&days=3
```

### Returns

* Marine forecast
* Wave height
* Swell information
* Tide data (plan dependent)

---

# 6. Location Search

Search cities and locations.

### Endpoint

```http
GET /search.json
```

### Parameters

| Name | Required | Description    |
| ---- | -------- | -------------- |
| q    | ✅        | Search keyword |

### Example

```http
/ search.json?q=Alex
```

### Returns

List of matching locations.

---

# 7. IP Lookup

Get location details from an IP address.

### Endpoint

```http
GET /ip.json
```

### Parameters

| Name | Required | Description |
| ---- | -------- | ----------- |
| q    | ✅        | IP Address  |

### Example

```http
/ ip.json?q=8.8.8.8
```

### Returns

* Country
* City
* Latitude/Longitude
* Timezone

---

# 8. Time Zone

Get timezone information for a location.

### Endpoint

```http
GET /timezone.json
```

### Parameters

| Name | Required | Description |
| ---- | -------- | ----------- |
| q    | ✅        | Location    |

### Example

```http
/ timezone.json?q=Cairo
```

### Returns

* Timezone ID
* Local time
* Geographic information

---

# 9. Astronomy

Get astronomy information for a location and date.

### Endpoint

```http
GET /astronomy.json
```

### Parameters

| Name | Required | Description |
| ---- | -------- | ----------- |
| q    | ✅        | Location    |
| dt   | ✅        | Date        |

### Example

```http
/ astronomy.json?q=Cairo&dt=2026-06-10
```

### Returns

* Sunrise
* Sunset
* Moonrise
* Moonset
* Moon phase
* Moon illumination

---

# Common Error Responses

| Code | Meaning                    |
| ---- | -------------------------- |
| 1002 | API key missing            |
| 2006 | Invalid API key            |
| 2007 | Monthly quota exceeded     |
| 2008 | API key disabled           |
| 1003 | Required parameter missing |
| 1006 | Location not found         |
| 9999 | Internal server error      |

---

# Recommended Mobile App Usage

| Screen           | Endpoint                |
| ---------------- | ----------------------- |
| Home Weather     | `/current.json`         |
| Forecast Screen  | `/forecast.json`        |
| Search City      | `/search.json`          |
| Weather Details  | `/forecast.json`        |
| Air Quality      | `/current.json?aqi=yes` |
| Astronomy Screen | `/astronomy.json`       |
| Timezone Display | `/timezone.json`        |
