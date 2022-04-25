const express = require("express");
var bodyParser = require('body-parser');
const port = 3000;
const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const createRecord = require("./createRecord");
const queryRecordByRollNumber = require("./queryRecordByRollNumber");
const queryRecordByHashCode = require("./queryRecordByHashCode");

app.post("/createRecord", (req, res) => {
    if(!req.body.rollNumber){
        return res.status(400).send({
            message:"Roll number not found"
        });
    }
    createRecord.execute(
        req.body.rollNumber,
        req.body.studentName,
        req.body.yearPassing,
        req.body.programName,
        req.body.durationProgram,
        req.body.certificateHash,
        req.body.documentFormat,
        req.body.documentType
       )
    .then(() => {
      console.log("Record added");
      const result = {
        status: "success",
        message: "Record added succcesfully",
      };
      res.json(result);
    })
    .catch((e) => {
      const result = {
        status: "error",
        message: "failed",
        error: e,
      };
      res.status(500).send(result);
    });
});

app.get("/queryRecordByRollNumber", (req, res) => {
    if(!req.query.rollNumber){
        return res.status(400).send({
            message:"Roll number not found"
        });
    }
    queryRecordByRollNumber.execute(req.query.rollNumber)
    .then((response) => {
      const result = {
        status: "success",
        message: "Student Details Fetched successfully",
        data: response
      };
      res.json(result);
    })
    .catch((e) => {
      const result = {
        status: "error",
        message: "failed",
        error: e,
      };
      res.status(500).send(result);
    });
});

app.get("/queryRecordByHashCode", (req, res) => {
    if(!req.query.certificateHash){
        return res.status(400).send({
            message:"CertificateHash not found"
        });
    }
    queryRecordByHashCode.execute(req.query.certificateHash)
    .then((response) => {
      const result = {
        status: "success",
        message: "Student Details Fetched successfully",
        data: response
      };
      res.json(result);
    })
    .catch((e) => {
      const result = {
        status: "error",
        message: "failed",
        error: e,
      };
      res.status(500).send(result);
    });
});

app.get("/getoneDetails", (req, res) => {
 
  if(!req.query.rollNumber){
    return res.status(400).send({
        message:"Roll number not found"
    });
}
queryRecordByRollNumber.execute(req.query.rollNumber)
.then((response) => {
  const result = {
    status: "success",
    message: "Student Details Fetched successfully",
    data: response
  };
  res.json(result);
})
.catch((e) => {
  const result = {
    status: "error",
    message: "failed",
    error: e,
  };
  res.status(500).send(result);
});
});

app.get('/getApp',(req,res)=>{
  res.json({ message: "welcome to my application" });
});
app.listen(port, () => console.log("IIM Application listening on port  3000 "));
