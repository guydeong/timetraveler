db.createUser({
  user: "timetraveler_admin",
  pwd: "TimeTravel2025Secure",
  roles: [
    { role: "readWrite", db: "timetraveler" },
    { role: "dbAdmin", db: "timetraveler" }
  ]
});