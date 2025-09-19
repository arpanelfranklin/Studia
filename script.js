const express = require("express");
const app = express();
const port = 3000;
const path = require("path");
const mysql = require("mysql2");

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
  const {
    day_of_week,
    start_time,
    end_time,
    classroom,
    subject_name,
    faculty_id,
    faculty_name,
    type,
    batch_id,
  } = req.body;

  // Step 1: Check conflict
  const qCheck = `
    SELECT * FROM timetable
    WHERE day_of_week = ?
      AND classroom = ?
      AND (
        (start_time < ? AND end_time > ?)   -- new start inside existing
        OR (start_time < ? AND end_time > ?) -- new end inside existing
        OR (start_time >= ? AND end_time <= ?) -- existing fully inside new
      )
  `;

  connection.query(
    qCheck,
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
        return res.status(500).send("Database error while checking conflicts.");
      }

      if (result.length > 0) {
        // Conflict found
        return res.render("conflict", {
          error: "Conflict detected! Please choose another slot.",
          conflicts: result,
        });
      }

      // Step 2: Insert since no conflict
      const qInsert = `
        INSERT INTO timetable (day_of_week, start_time, end_time, classroom, subject_name, faculty_id, faculty_name, type, batch_id)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      `;

      connection.query(
        qInsert,
        [
          day_of_week,
          start_time,
          end_time,
          classroom,
          subject_name,
          faculty_id,
          faculty_name,
          type,
          batch_id,
        ],
        (err2) => {
          if (err2) {
            console.log(err2);
            res.render("conflict");
            return res.status(500).send("Error inserting timetable entry.");
          }

          res.render("timetableconfirm", {
            success: "Timetable entry added successfully ✅",
          });
        }
      );
    }
  );
});

app.get("/facultydashboard", (req, res) => {
  res.render("facultydashboard.ejs");
});
app.get("/conflict", (req, res) => {
  res.render("conflict");
});
