const express = require('express');
const bodyParser = require('body-parser');
const mongoose = require('mongoose');

const app = express();
const port = 3000;

app.use(bodyParser.json());


mongoose.connect('mongodb+srv://iiitianshauryashakya8055:99359990852%40Adh@shop.jiobekx.mongodb.net/?retryWrites=true&w=majority&appName=shop');
const db = mongoose.connection;
db.on('error', (error) => console.error(error));
db.once('open', () => console.log('Connected to Database'));

// Define User Schema and Model
const { Schema, model } = mongoose;
const userSchema = new Schema({
  name: String,
  age: Number,
  email: String
});
const User = model('User', userSchema);

//TODO:  this
app.post('/',(req,res)=>{
  const {name,age,email}= req.body;
  const newUser = new User({
    name,
    age,
    email
  });
  newUser.save();
  res.json('User created successfully');
})







app.listen(port, () => {
  console.log(`Server is running on :${port}`);
});