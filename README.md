# ZenPay - Banca Digital

Plataforma financiera digital premium construida con **Angular 21** + **Spring Boot 3** + **PostgreSQL**. PWA instalable en iPhone y Android.

## 🚀 Demo

- **Frontend**: https://zen-pay-5cep.vercel.app
- **Backend**: https://zenpay-api.onrender.com
- **Credenciales demo**: `vanessa@zenpay.com` / `admin123`

## 🛠 Stack

| Capa | Tecnología |
|---|---|
| Frontend | Angular 21, Angular Material, PWA, SCSS |
| Backend | Spring Boot 3, Spring Security, JWT, Flyway |
| Base de datos | PostgreSQL 18 (Neon) |
| Deploy | Vercel + Render |

## ✨ Funcionalidades

- Dashboard financiero con cards y gráficos
- Transferencias bancarias y pagos QR
- Recargas móviles y pago de servicios
- Gestión de tarjetas, metas de ahorro, créditos e inversiones
- Asistente IA integrado
- Geolocalización de cajeros y bancos
- Modo oscuro / claro
- PWA instalable (offline-ready)

## 🔐 Seguridad

- Autenticación JWT con refresh token
- CORS restringido por entorno
- Contraseñas hasheadas con bcrypt
- Migraciones Flyway versionadas
- Variables de entorno para secretos

## 📱 PWA

- Manifest y service worker
- Iconos SVG 192x192 y 512x512
- Apple touch icon 180x180
- Safe-area para iPhone X+
- Responsive: iPhone 13/14/15, Android 360px+
- Sidebar drawer tipo Nequi/Nubank

## 🏗 Arquitectura

```
ZenPay/
├── src/                    # Frontend Angular
│   ├── app/
│   │   ├── features/       # Módulos funcionales
│   │   ├── layout/         # Sidebar, navbar, main-layout
│   │   └── shared/         # Servicios, stores, modelos
│   ├── environments/       # Config por entorno
│   └── styles.scss         # Estilos globales
├── backend/                # Backend Spring Boot
│   ├── src/main/java/      # Código Java
│   ├── src/main/resources/ # Config, migraciones Flyway
│   └── Dockerfile          # Multi-stage build
├── public/                 # PWA assets
└── vercel.json             # Config deploy Vercel
```

## 🚦 Cómo ejecutar local

```bash
# Frontend
npm install
ng serve  # → http://localhost:4200

# Backend (requiere PostgreSQL local)
cd backend
./mvnw spring-boot:run
```
