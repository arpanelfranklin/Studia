const express = require("express");
const app = express();
const port = 3000;
const path = require("path");
const mysql = require("mysql2");
const { faker } = require("@faker-js/faker");
const database = require("mime-db");
const connection = mysql.createConnection({
  host: "localhost",
  user: "root",
  database: "studia",
  password: "arpanelisbest",
  port: 8080,
});
const session = require("express-session");

app.use(
  session({
    secret: "supersecretkey", // change this to a strong secret
    resave: false,
    saveUninitialized: false,
    cookie: { maxAge: 24 * 60 * 60 * 1000 }, // 1 day
  })
);

app.set("views", path.join(__dirname, "views"));
app.set("view engine", "ejs");

app.use(express.static(path.join(__dirname, "public")));
app.use(express.urlencoded({ extended: true }));

app.listen(port, (req, res) => {
  console.log("Server is working");
});

app.get("/", (req, res) => {
  res.render("newstudentlogin.ejs");
});

app.get("/curriculum", (req, res) => {
  res.render("curriculum.ejs");
});
app.post("/facultylogin", (req, res) => {
  const { email, password } = req.body;
  console.log(email, password);
  const q = `
    SELECT 
      f.*
    FROM facultylogin f
    WHERE f.email = ? AND f.password = ?;
  `;

  connection.query(q, [email, password], (error, results) => {
    if (error) {
      console.error(error);
      return res.send("Database error");
    }

    if (results.length > 0) {
      const facultyData = results[0];

      // ✅ Store logged-in faculty in session
      req.session.faculty = facultyData;

      res.redirect("/facultydashboard");
    } else {
      res.render("wrongidpass.ejs");
    }
  });
});

app.get("/facultylogin", (req, res) => {
  res.render("newfacultylogin.ejs");
});
app.get("/pricing", (req, res) => {
  res.send("at pricing ");
});

app.get("/support", (req, res) => {
  res.send("at support ");
});

// app.get("/login", (req, res) => {
//   res.render("studentlogin.ejs");
// });
app.get("/setting", (req, res) => {
  res.render("setting.ejs");
});

app.post("/login", (req, res) => {
  const { email, password } = req.body;

  const q = `
    SELECT 
      s.*, 
      b.*, 
      br.*
    FROM registeredUser u
    JOIN studentdashboard s ON u.studentID = s.student_id
    JOIN batch b ON s.batch_id = b.batch_id
    JOIN Branch br ON b.branch_id = br.branchID
    WHERE u.email = ? AND u.passwords = ?;
  `;

  connection.query(q, [email, password], (error, results) => {
    if (error) {
      console.error(error);
      return res.send("Database error");
    }

    if (results.length > 0) {
      const studentData = results[0];

      // ✅ Store logged-in user in session
      req.session.student = studentData;

      res.redirect("/home");
    } else {
      res.render("wrongidpass.ejs");
    }
  });
});

app.get("/home", (req, res) => {
  if (!req.session.student) {
    return res.redirect("/"); // not logged in, redirect to login
  }

  let q = "SELECT * FROM timetable";
  connection.query(q, (error, rows) => {
    if (error) {
      console.log(error);
      return res.send("SOME ERROR IN DATABASE");
    } else {
      console.log(rows);

      res.render("studentDashboard.ejs", {
        studentData: req.session.student,
        result: rows, // ✅ rows is an array
      });
    }
  });
});

app.get("/physics", (req, res) => {
  res.render("physics.ejs");
});

app.get("/timetable", (req, res) => {
  if (!req.session.student) return res.redirect("/"); // redirect if not logged in

  let q = "SELECT t.* from timetable t join batch b ON b.batch_id=t.batch_id";
  connection.query(q, (error, result) => {
    if (error) {
      res.send(error);
    } else {
      res.render("newtimetable.ejs", { results: result });
    }
  });
});

app.get("/assignments", (req, res) => {
  res.render("assignments.ejs");
});
app.get("/grades", (req, res) => {
  res.render("grades.ejs");
});
app.get("/facultytimetable", (req, res) => {
  let q = "select * from timetable";
  connection.query(q, (error, result) => {
    if (error) {
      console.log(error);
      res.send("SOME ERROR IN DATABASE");
    } else {
      console.log(result);
      res.render("facultytimetablenew.ejs", { result });
    }
  });
});
app.post("/addtimetable", (req, res) => {
  const data = req.body;

  const values = [
    data.batch_id,
    data.day_of_week, // use lowercase (check your form name too)
    data.subject_name,
    data.start_time,
    data.end_time,
    data.classroom,
    data.faculty_name,
    data.faculty_id, // required column
    data.type, // char(1), e.g., 'L', 'P', 'T'
  ];
  console.log(values);

  const q = `INSERT INTO timetable 
    (batch_id, day_of_week, subject_name, start_time, end_time, classroom, faculty_name, faculty_id, type) 
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`;

  console.log("Query:", q);
  console.log("Values:", values);

  connection.query(q, values, (err, result) => {
    if (err) {
      console.error("SQL Error:", err);
      return res.status(500).json(err);
    }
    res.render("timetableconfirm.ejs");
  });
});

// Check timetable conflicts
// Check classroom conflicts
app.get("/checkconflict", (req, res) => {
  const { day_of_week, start_time, end_time, classroom } = req.query;
  console.log(req.query);

  const q = `
    SELECT * FROM timetable
    WHERE day_of_week = ?
      AND classroom = ?
      AND (
        (start_time < ? AND end_time > ?)   -- new start is inside existing
        OR (start_time < ? AND end_time > ?) -- new end is inside existing
        OR (start_time >= ? AND end_time <= ?) -- completely inside new slot
      )
  `;

  connection.query(
    q,
    [
      day_of_week,
      classroom,
      end_time,
      start_time,
      end_time,
      start_time,
      start_time,
      end_time,
    ],
    (error, result) => {
      if (error) {
        console.log(error);
        res.status(500).send("Database error while checking conflicts.");
      } else if (result.length > 0) {
        res.json({ conflict: true, conflicts: result });
      } else {
        res.json({ conflict: false, message: "No conflicts found ✅" });
      }
    }
  );
});

app.get("/facultydashboard", (req, res) => {
  res.render("facultydashboard.ejs");
});
