#!/bin/bash

echo "🚀 Création du backend MERN pour le recouvrement clients..."

# === Nom du projet
mkdir recouvrement-backend
cd recouvrement-backend

# === Init npm + install des modules
npm init -y

echo "📦 Installation des dépendances..."
npm install express mongoose dotenv bcryptjs jsonwebtoken passport passport-jwt cors body-parser
npm install nodemon --save-dev

# === Fichiers de config
mkdir config middleware models routes

# === .env sécurisé
echo "🔐 Configuration .env..."
cat <<EOF > .env
PORT=5000
MONGO_URI=mongodb+srv://BelikanM:Dieu19961991%3F%3F%21%3F%21%3F%21@cluster0.ue8e6gw.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0
JWT_SECRET=$(openssl rand -hex 32)
EOF

# === server.js
cat <<'EOF' > server.js
const express = require("express");
const mongoose = require("mongoose");
const passport = require("passport");
const cors = require("cors");
require("dotenv").config();

const authRoutes = require("./routes/auth");
const clientRoutes = require("./routes/clients");
const creanceRoutes = require("./routes/creances");

require("./config/passport")(passport);

const app = express();

app.use(cors());
app.use(express.json());
app.use(passport.initialize());

mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log("✅ MongoDB connecté"))
  .catch((err) => console.error("❌ Erreur MongoDB", err));

app.use("/api/auth", authRoutes);
app.use("/api/clients", passport.authenticate("jwt", { session: false }), clientRoutes);
app.use("/api/creances", passport.authenticate("jwt", { session: false }), creanceRoutes);

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(\`🚀 Serveur en ligne sur http://localhost:\${PORT}\`));
EOF

# === config/passport.js
cat <<'EOF' > config/passport.js
const { Strategy, ExtractJwt } = require("passport-jwt");
const mongoose = require("mongoose");
const User = require("../models/User");
require("dotenv").config();

const opts = {
  jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
  secretOrKey: process.env.JWT_SECRET,
};

module.exports = (passport) => {
  passport.use(
    new Strategy(opts, async (jwt_payload, done) => {
      try {
        const user = await User.findById(jwt_payload.id);
        if (user) return done(null, user);
        return done(null, false);
      } catch (err) {
        return done(err, false);
      }
    })
  );
};
EOF

# === models/User.js
cat <<'EOF' > models/User.js
const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  role: { type: String, default: "agent" }
}, { timestamps: true });

module.exports = mongoose.model("User", userSchema);
EOF

# === routes/auth.js
cat <<'EOF' > routes/auth.js
const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const User = require("../models/User");
const router = express.Router();

router.post("/register", async (req, res) => {
  const { email, password } = req.body;
  try {
    const exists = await User.findOne({ email });
    if (exists) return res.status(400).json({ message: "Utilisateur existe déjà" });

    const hashed = await bcrypt.hash(password, 10);
    const user = new User({ email, password: hashed });
    await user.save();
    res.json({ message: "Utilisateur enregistré" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.post("/login", async (req, res) => {
  const { email, password } = req.body;
  try {
    const user = await User.findOne({ email });
    if (!user) return res.status(400).json({ message: "Utilisateur non trouvé" });

    const match = await bcrypt.compare(password, user.password);
    if (!match) return res.status(400).json({ message: "Mot de passe incorrect" });

    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: "1d" });
    res.json({ token, user: { id: user._id, email: user.email } });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
EOF

# === routes/clients.js vide
cat <<'EOF' > routes/clients.js
const express = require("express");
const router = express.Router();

// Routes à compléter pour gérer les clients

router.get("/", (req, res) => {
  res.json({ message: "Liste des clients à venir" });
});

module.exports = router;
EOF

# === routes/creances.js vide
cat <<'EOF' > routes/creances.js
const express = require("express");
const router = express.Router();

// Routes à compléter pour gérer les créances

router.get("/", (req, res) => {
  res.json({ message: "Liste des créances à venir" });
});

module.exports = router;
EOF

# === .gitignore
echo "node_modules\n.env" > .gitignore

# === Scripts
echo '{
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  }
}' | jq -s '.[1] * .[0]' package.json > tmp.$$.json && mv tmp.$$.json package.json

echo "✅ Backend prêt. Lance avec : cd recouvrement-backend && npm run dev"
