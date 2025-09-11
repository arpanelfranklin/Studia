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

// Generates fake 20 user data
// let registeredUser = [];

// for (let i = 1; i <= 20; i++) {
//   let randomuser = () => ({
//     // userId: faker.string.uuid(),
//     username: faker.internet.username(),
//     email: faker.internet.email(),
//     // avatar: faker.image.avatar(),
//     password: faker.internet.password(),
//     // birthdate: faker.date.birthdate(),
//     // registeredAt: faker.date.past(),
//   });

//   registeredUser.push(randomuser());
// }

// for (let i = 0; i < registeredUser.length; i++) {
//   let user = [
//     registeredUser[i]["username"],
//     registeredUser[i]["email"],
//     registeredUser[i]["password"],
//   ];
//   let q =
//     "INSERT INTO registeredUser (Username,email,passwords) VALUES (?,?,?)";
//   connection.query(q, user, (error) => {
//     if (error) {
//       console.log(error);
//     }
//   });
// }

app.set("views", path.join(__dirname, "views"));
app.set("view engine", "ejs");

app.use(express.static(path.join(__dirname, "public")));
app.use(express.urlencoded({ extended: true }));

app.listen(port, (req, res) => {
  console.log("Server is working");
});

app.get("/", (req, res) => {
  res.render("studentlogin.ejs");
});

app.get("/Features", (req, res) => {
  res.send("you are at features points");
});
app.get("/facultylogin", (req, res) => {
  res.render("faculyLogin.ejs");
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

      console.log(studentData);

      res.render("studentDashboard.ejs", {
        studentData,
      });
    } else {
      res.send("Invalid email or password");
    }
  });
});

app.get("/timetable", (req, res) => {
  let q = "SELECT t.* from timetable t join batch b ON b.batch_id=t.batch_id";
  connection.query(q, (error, result) => {
    if (error) {
      res.send(error);
    } else {
      console.log(result);
      res.render("timetable.ejs", { results: result });
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
      res.render("facultytimetable.ejs", { result });
    }
  });
});
app.post("/addtimetable", (req, res) => {
  // form sends urlencoded -> works if express.urlencoded() is enabled
  const data = req.body;

  // map form field names to DB column names
  const values = [
    data.batch_id,
    data.day_Of_Week, // enum('Monday','Tuesday',...)
    data.subject_name,
    data.start_time,
    data.end_time,
    data.classroom,
    data.faculty_name,
    data.type,
  ];

  const q = `INSERT INTO timetable 
    (batch_id, day_of_week, subject_name, start_time, end_time, classroom, faculty_name, type) 
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)`;

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
