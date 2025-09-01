const express = require("express");
const app = express();
const port = 8080;
const path = require("path");

app.set("views", path.join(__dirname, "views"));
app.set("view engine", "ejs");

app.use(express.static(path.join(__dirname, "public")));
app.use(express.urlencoded({ extended: true }));

app.listen(port, (req, res) => {
  console.log("Server is working");
});

app.get("/", (req, res) => {
  res.render("home.ejs");
});

app.get("/Features", (req, res) => {
  res.send("you are at features points");
});

app.get("/pricing", (req, res) => {
  res.send("at pricing ");
});

app.get("/support", (req, res) => {
  res.send("at support ");
});

app.get("/login", (req, res) => {
  res.render("login.ejs", { registeredEmails });
});
app.post("/login", (req, res) => {
  let { email, password, username } = req.body;
  let details = req.body;
  try {
    for (logins of registeredEmails) {
      if (email === logins.email) {
        if (password === logins.password) {
          let username = logins.username;
          res.render("dashboard.ejs", { username });
        } else {
          res.send("Wrong password");
        }
      } else {
        res.send("email not registered");
      }
    }
  } catch (e) {
    console.log(e);
  }
});

let registeredEmails = [
  {
    email: "SadieSink@gmail.com",
    password: "maxine22@$mayfield",
    username: "SadieSink",
  },
];
