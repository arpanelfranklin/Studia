const express = require("express");
const app = express();
const port = 3000;
const path = require("path");
const mysql = require("mysql2");
const ntpClient = require("ntp-client");
const QRCode = require("qrcode");
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

app.post("/facultylogin", async (req, res) => {
  const { email, password } = req.body;
  try {
    const loginResults = await new Promise((resolve, reject) => {
      const q = "SELECT * FROM facultylogin WHERE email = ? AND password = ?";
      connection.query(q, [email, password], (err, results) =>
        err ? reject(err) : resolve(results)
      );
    });

    if (loginResults.length === 0) {
      return res.render("wrongidpass.ejs");
    }

    const faculty = loginResults[0];
    const facultyId = faculty.faculty_id;

    const [
      dashboardResults,
      leavesResults,
      ratingsResults,
      timetableResults,
      totalClassrooms,
    ] = await Promise.all([
      new Promise((resolve, reject) => {
        connection.query(
          "SELECT * FROM faculty_dashboard WHERE faculty_id = ?",
          [facultyId],
          (err, results) => (err ? reject(err) : resolve(results))
        );
      }),
      new Promise((resolve, reject) => {
        connection.query(
          "SELECT * FROM faculty_leaves WHERE faculty_id = ?",
          [facultyId],
          (err, results) => (err ? reject(err) : resolve(results))
        );
      }),
      new Promise((resolve, reject) => {
        connection.query(
          "SELECT * FROM faculty_ratings WHERE faculty_id = ?",
          [facultyId],
          (err, results) => (err ? reject(err) : resolve(results))
        );
      }),
      new Promise((resolve, reject) => {
        const q = `
            SELECT t.*, c.classroom_id, c.capacity, c.resources
            FROM timetable t
            LEFT JOIN classrooms c ON t.classroom = c.room_number
            WHERE t.faculty_id = ?;
          `;
        connection.query(q, [facultyId], (err, results) =>
          err ? reject(err) : resolve(results)
        );
      }),
      new Promise((resolve, reject) => {
        connection.query(
          "SELECT COUNT(*) AS totalAvailable FROM classrooms",
          (err, results) => (err ? reject(err) : resolve(results))
        );
      }),
    ]);

    const fullFacultyData = {
      login: faculty,
      dashboard: dashboardResults[0] || {},
      leaves: leavesResults,
      ratings: ratingsResults,
      timetable: timetableResults,
      totalClassroomsAvailable: totalClassrooms[0].totalAvailable || 0,
    };

    req.session.faculty = fullFacultyData;

    // 🔑 Ensure session is saved before redirect
    req.session.save((err) => {
      if (err) console.log(err);
      res.redirect("/facultydashboard");
    });
  } catch (error) {
    console.error("Error fetching faculty data:", error);
    res.send("Database error");
  }
});

app.get("/facultylogin", (req, res) => {
  res.render("newfacultylogin.ejs");
});
function ensureFacultyLoggedIn(req, res, next) {
  if (!req.session.faculty) {
    return res.redirect("/facultylogin");
  }
  next();
}

app.get("/facultydashboard", ensureFacultyLoggedIn, (req, res) => {
  res.render("facultydashboard", {
    fullFacultyData: req.session.faculty,
  });
});

app.get("/pricing", (req, res) => {
  res.send("at pricing ");
});

app.get("/support", (req, res) => {
  res.send("at support ");
});

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

app.get("/conflict", (req, res) => {
  res.render("conflict");
});

function getIndiaTime(callback) {
  ntpClient.getNetworkTime("pool.ntp.org", 123, (err, date) => {
    if (err) {
      console.error("❌ NTP Error:", err);
      return callback(null);
    }
    // Convert UTC to IST (+5:30)
    const istOffset = 5.5 * 60; // in minutes
    const istDate = new Date(date.getTime() + istOffset * 60 * 1000);
    callback(istDate);
  });
}

async function backupAndClearTimetable() {
  try {
    console.log("Starting backup & clear timetable...");

    await connection
      .promise()
      .query(`CREATE TABLE IF NOT EXISTS timetable_backup LIKE timetable;`);
    console.log("Backup table ready.");

    const [backupResult] = await connection
      .promise()
      .query(`INSERT INTO timetable_backup SELECT * FROM timetable;`);
    console.log("Backup rows inserted:", backupResult.affectedRows);

    const [deleteResult] = await connection
      .promise()
      .query(`DELETE FROM timetable;`);
    console.log("Deleted rows:", deleteResult.affectedRows);
    console.log("🗑️ Timetable cleared for the new week.");
  } catch (err) {
    console.error("❌ Error in backup & clear:", err);
  }
}

// Check every minute
setInterval(() => {
  getIndiaTime((currentTime) => {
    if (!currentTime) return;

    const day = currentTime.getDay(); // 5 = Friday
    const hours = currentTime.getHours(); // 23
    const minutes = currentTime.getMinutes(); // 59

    if (day === 5 && hours === 23 && minutes === 59) {
      backupAndClearTimetable();
    } else {
      console.log(
        `Waiting... Current IST: ${currentTime.toLocaleString("en-IN")}`
      );
    }
  });
}, 60 * 1000); // every 1 minute

app.get("/facultytimetable", ensureFacultyLoggedIn, (req, res) => {
  const q = "SELECT * FROM timetable WHERE faculty_id = ?";
  connection.query(q, [req.session.faculty.login.faculty_id], (err, result) => {
    if (err) return res.send("SOME ERROR IN DATABASE");

    const q1 = "SELECT COUNT(*) AS totalClassrooms FROM classrooms";
    connection.query(q1, (error, classroomResult) => {
      if (error) return res.send("SOME ERROR IN DATABASE");

      console.log("Timetable:", result);
      console.log("Classrooms:", classroomResult);

      res.render("facultytimetablenew", {
        fullFacultyData: req.session.faculty,
        result: result,
        totalClassrooms: classroomResult[0].totalClassrooms,
      });
    });
  });
});

let attendance = {}; // e.g., { studentId: true }
app.get("/markattendance", async (req, res) => {
  try {
    // For demo, we generate a QR code pointing to "/attend?studentId=123"
    const studentId = "123"; // In real app, generate unique ID for session/student
    const urlToEncode = `http://localhost:${port}/attend?studentId=${studentId}`;

    // Generate QR code as data URL
    const qrDataUrl = await QRCode.toDataURL(urlToEncode, {
      color: { dark: "#000000ff", light: "#F0EDEE" },
    });

    res.render("markattendance", { qrDataUrl });
  } catch (err) {
    console.error(err);
    res.send("Error generating QR code");
  }
});
// When the QR code is scanned, user goes to this route
app.get("/attend", (req, res) => {
  const studentId = req.query.studentId;
  if (!studentId) return res.send("Invalid QR code");

  // Mark attendance
  attendance[studentId] = true;

  res.send(`<h1 style="font-family:sans-serif;color:#07393C">
    ✅ Attendance marked for Student ID: ${studentId}
  </h1>`);
});
app.get("/attendance-status", (req, res) => {
  res.json(attendance);
});

app.get("/applyleave", (req, res) => {
  res.render("applyleave");
});

app.post("/applyleave", (req, res) => {
  console.log(req.body);
  const { faculty_id, facultyName, from_date, to_date, reason } = req.body;

  // Basic validation
  if (!faculty_id || !facultyName || !from_date || !to_date || !reason) {
    return res.status(400).send("Please fill all required fields");
  }

  // Default leave_type if not provided
  const type = "Other";

  // Insert into DB
  const q = `
    INSERT INTO faculty_leaves
    (faculty_id, facultyName, leave_type, reason, status, fromDate, toDate)
    VALUES (?, ?, ?, ?, 'Pending', ?, ?)
  `;

  connection.query(
    q,
    [faculty_id, facultyName, type, reason, from_date, to_date],
    (err, result) => {
      if (err) {
        console.error("Error inserting leave:", err);
        return res.status(500).send("Database error while applying leave.");
      }
      res.render("timetableconfirm", {
        message: "Leave application submitted successfully ✅",
      });
    }
  );
});

// Fetch pending leaves
app.get("/adminaccess", (req, res) => {
  const q = "SELECT * FROM faculty_leaves WHERE status = 'Pending'";
  connection.query(q, (err, results) => {
    if (err) {
      console.error("Error fetching leaves:", err);
      return res.status(500).send("Database error while fetching leaves.");
    }
    res.render("adminaccess", { leaves: results });
  });
});

// Approve leave
app.post("/leaves/:id/approve", (req, res) => {
  const leaveId = req.params.id;
  const q = "UPDATE faculty_leaves SET status = 'Approved' WHERE leave_id = ?";
  connection.query(q, [leaveId], (err, result) => {
    if (err) {
      console.error("Error approving leave:", err);
      return res.status(500).json({ success: false });
    }
    res.json({ success: true, status: "Approved" });
  });
});

app.post("/leaves/:id/reject", (req, res) => {
  const leaveId = req.params.id;
  const q = "UPDATE faculty_leaves SET status = 'Rejected' WHERE leave_id = ?";
  connection.query(q, [leaveId], (err, result) => {
    if (err) {
      console.error("Error rejecting leave:", err);
      return res.status(500).json({ success: false });
    }
    res.json({ success: true, status: "Rejected" });
  });
});

app.post("/addbatch", (req, res) => {
  const { batch_id, branch_id, year, semester, branch_code, mentor } = req.body;

  const q = `
    INSERT INTO batch (batch_id,branch_id, year, semester, branch_code, mentor)
    VALUES (?,?, ?, ?, ?, ?)
  `;

  connection.query(
    q,
    [batch_id, branch_id, year, semester, branch_code || null, mentor || null],
    (err, result) => {
      if (err) {
        console.error("Error inserting batch:", err);
        return res.status(500).send("Database error while adding batch.");
      }
      res.redirect("/adminaccess");
    }
  );
});

app.post("/addstudent", (req, res) => {
  const { studentID, email, passwords } = req.body;

  const q = `
    INSERT INTO registeredUser (studentID, email, passwords)
    VALUES (?, ?, ?)
  `;

  connection.query(q, [studentID, email, passwords], (err, result) => {
    if (err) {
      console.error("Error inserting student:", err);
      return res.status(500).send("Database error while adding student.");
    }
    res.redirect("/adminaccess");
  });
});
app.post("/addFaculty", (req, res) => {
  const { faculty_id, email, password } = req.body;

  const sql =
    "INSERT INTO facultylogin (faculty_id, email, password) VALUES (?, ?, ?)";
  connection.query(sql, [faculty_id, email, password], (err, result) => {
    if (err) {
      console.error("Error inserting faculty:", err);
      return res.status(500).send("Error inserting faculty");
    }
    console.log("Faculty added:", result);
    res.redirect("adminaccess");
  });
});
app.post("/addBranch", (req, res) => {
  const { branchName, branchCode } = req.body;

  const sql = "INSERT INTO branch (branchName, branchCode) VALUES (?, ?)";
  db.query(sql, [branchName, branchCode], (err, result) => {
    if (err) {
      console.error("Error inserting branch:", err);
      return res.status(500).send("Error inserting branch");
    }
    res.status(200).send("Branch added successfully");
  });
});
