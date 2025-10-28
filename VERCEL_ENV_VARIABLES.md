# ⚡ Quick Start: Vercel Environment Variables

## 🎯 Action Required: Set These in Vercel Dashboard

Go to: **Vercel Dashboard → Your Project → Settings → Environment Variables**

---

### 1️⃣ API_BASE_URL

```
Name:  API_BASE_URL
Value: http://localhost:3000
```

**Note**: Change to your production API URL when backend is deployed

---

### 2️⃣ GEMINI_API_KEY

```
Name:  GEMINI_API_KEY
Value: YOUR_GEMINI_API_KEY_HERE
```

**Get it from**: https://aistudio.google.com/app/apikey

---

### 3️⃣ GOOGLE_MAPS_API_KEY

```
Name:  GOOGLE_MAPS_API_KEY
Value: YOUR_GOOGLE_MAPS_API_KEY_HERE
```

**Get it from**: https://console.cloud.google.com/apis/credentials

---

## ✅ For Each Variable:

1. Click "Add New"
2. Enter Name (exactly as shown above)
3. Enter Value (your actual API key)
4. Select environments:
   - ✅ Production
   - ✅ Preview
   - ✅ Development
5. Click "Save"

---

## 🚀 After Setting All Variables:

1. Go to "Deployments" tab
2. Click "Redeploy" on the latest deployment
3. Select "Use existing Build Cache: No"
4. Click "Redeploy"

---

## ⚠️ Important Notes:

- **DO NOT** commit API keys to GitHub
- **DO** keep your `.env` file for local development
- **DO** set API restrictions on Google Cloud Console
- **DO** rotate any exposed keys immediately

---

**Build will fail without these variables set!**

After adding them, commit your code changes and push to trigger a new build.
