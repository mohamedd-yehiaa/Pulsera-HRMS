// ==========================
// 1. LOOKUP TABLES (Execute First)
// ==========================

const String createTableRoles = '''
CREATE TABLE Roles (
  role_id INTEGER PRIMARY KEY AUTOINCREMENT,
  role_name TEXT NOT NULL UNIQUE
);
''';

const String createTableDepartments = '''
CREATE TABLE Departments (
  department_id INTEGER PRIMARY KEY AUTOINCREMENT,
  department_name TEXT NOT NULL UNIQUE
);
''';

const String createTableDesignations = '''
CREATE TABLE Designations (
  designation_id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL UNIQUE
);
''';

const String createTableLeaveTypes = '''
CREATE TABLE Leave_Types (
  leave_type_id INTEGER PRIMARY KEY AUTOINCREMENT,
  type_name TEXT NOT NULL UNIQUE
);
''';

const String createTableStatuses = '''
CREATE TABLE Statuses (
  status_id INTEGER PRIMARY KEY AUTOINCREMENT,
  status_name TEXT NOT NULL UNIQUE
);
''';

// ==========================
// 2. CORE TABLES (Execute Second)
// ==========================

const String createTableUsers = '''
CREATE TABLE Users (
  user_id INTEGER PRIMARY KEY AUTOINCREMENT,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  role_id INTEGER NOT NULL,
  FOREIGN KEY (role_id) REFERENCES Roles (role_id)
);
''';

const String createTableEmployees = '''
CREATE TABLE Employees (
  employee_id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL UNIQUE,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  phone TEXT,
  address_street TEXT,
  address_city TEXT,
  address_zip TEXT,
  designation_id INTEGER,
  department_id INTEGER,
  basic_salary REAL,
  join_date TEXT, -- Store as ISO8601 string 'YYYY-MM-DD'
  FOREIGN KEY (user_id) REFERENCES Users (user_id) ON DELETE CASCADE,
  FOREIGN KEY (designation_id) REFERENCES Designations (designation_id),
  FOREIGN KEY (department_id) REFERENCES Departments (department_id)
);
''';

// ==========================
// 3. OPERATIONAL TABLES (Execute Last)
// ==========================

const String createTableBankDetails = '''
CREATE TABLE Employee_Bank_Details (
  bank_detail_id INTEGER PRIMARY KEY AUTOINCREMENT,
  employee_id INTEGER NOT NULL,
  bank_name TEXT,
  account_number TEXT,
  routing_number TEXT,
  FOREIGN KEY (employee_id) REFERENCES Employees (employee_id) ON DELETE CASCADE
);
''';

const String createTableLeaveRequests = '''
CREATE TABLE Leave_Requests (
  request_id INTEGER PRIMARY KEY AUTOINCREMENT,
  employee_id INTEGER NOT NULL,
  approver_id INTEGER, -- Nullable if not yet approved
  leave_type_id INTEGER NOT NULL,
  status_id INTEGER NOT NULL,
  start_date TEXT NOT NULL,
  end_date TEXT NOT NULL,
  reason TEXT,
  manager_comment TEXT,
  applied_date TEXT NOT NULL,
  FOREIGN KEY (employee_id) REFERENCES Employees (employee_id) ON DELETE CASCADE,
  FOREIGN KEY (approver_id) REFERENCES Employees (employee_id),
  FOREIGN KEY (leave_type_id) REFERENCES Leave_Types (leave_type_id),
  FOREIGN KEY (status_id) REFERENCES Statuses (status_id)
);
''';

const String createTableAttendance = '''
CREATE TABLE Attendances (
  attendance_id INTEGER PRIMARY KEY AUTOINCREMENT,
  employee_id INTEGER NOT NULL,
  date TEXT NOT NULL,
  check_in TEXT, -- Store as ISO8601 'HH:MM:SS'
  check_out TEXT,
  status_id INTEGER,
  FOREIGN KEY (employee_id) REFERENCES Employees (employee_id) ON DELETE CASCADE,
  FOREIGN KEY (status_id) REFERENCES Statuses (status_id)
);
''';

const String createTablePayroll = '''
CREATE TABLE Payrolls (
  payroll_id INTEGER PRIMARY KEY AUTOINCREMENT,
  employee_id INTEGER NOT NULL,
  month_year TEXT NOT NULL, -- e.g., '2023-10'
  basic_salary_snapshot REAL,
  total_allowances REAL,
  total_deductions REAL,
  net_salary REAL,
  generated_date TEXT,
  is_paid INTEGER DEFAULT 0, -- 0 for false, 1 for true
  FOREIGN KEY (employee_id) REFERENCES Employees (employee_id) ON DELETE CASCADE
);
''';