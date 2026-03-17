# Reviewer Mobile Application

## Project Overview

**Reviewer** is an Android mobile application built using Flutter that helps college students review and memorize key academic terms.

The system works using **Meaning → Term answering**.
Students read a **definition or meaning** and must type the **correct term** that matches that meaning.

**Example:**

> Meaning: "What is the study of living organisms?"
>
> User Answer: "Biology"

If correct, the user proceeds to the next question.

The questions and answers are created by the **Admin** and stored in the **SQLite local database**.

The application works **offline** and is designed for **Android devices only**.

---

## System Objectives

1. Provide a mobile reviewer tool for college students.
2. Allow administrators to create subjects and meaning-based questions.
3. Allow users to answer questions by typing the correct academic term.
4. Provide immediate feedback for correct and incorrect answers.
5. Show quiz results and allow users to repeat quizzes.

---

## Technology Stack

### Frontend

| Item      | Detail           |
|-----------|------------------|
| Framework | Flutter          |
| Language  | Dart             |
| IDE       | Android Studio   |
| Platform  | Android only     |

### Database

| Item     | Detail               |
|----------|----------------------|
| Database | SQLite (local)       |
| Packages | sqflite, path, provider |

---

## Application Architecture

```
Flutter App
     |
SQLite Local Database
```

- No internet required
- Fully offline functionality
- Fast local data retrieval

---

## System Roles

### 1. Admin Role

The admin manages all review content in the application.

**Admin Features:**
- Admin Registration and Login
- Subject Management (Biology, Psychology, Computer Science, Mathematics, etc.)
- Meaning and Term Management

**Admin Functions:**
- Add / Edit / Delete Subject
- Add / Edit / Delete Questions
- View Question List

**Example Question:**

> Meaning: "The study of the human mind and behavior"
>
> Correct Term: `Psychology`

> ⚠️ The correct term is stored in the database but **not shown to the user until the answer is correct**.

---

### 2. User Role

Users are students who will answer the reviewer questions.

**User Features:**
- User Registration & Login
- Select Subject
- Answer Questions (type the correct term based on the displayed meaning)

**Answer Validation:**

| Result    | Behavior                                      |
|-----------|-----------------------------------------------|
| ✔ Correct | Display correct term → Proceed to next question |
| ✖ Incorrect | Stay on current question → Must try again   |

---

## Quiz Completion

After finishing all questions in a subject, the application shows the result.

**Example Result:**
```
Subject: Psychology

Total Questions:   20
Correct Answers:   18
Score:             90%
```

**Options:**
- Repeat Quiz
- Back to Subject List

Users may repeat quizzes anytime to improve their scores.

---

## Database Design

### Table: Users

| Field    | Type                  |
|----------|-----------------------|
| id       | INTEGER PRIMARY KEY   |
| name     | TEXT                  |
| email    | TEXT                  |
| password | TEXT                  |
| role     | TEXT (`admin` / `user`) |

---

### Table: Subjects

| Field        | Type                |
|--------------|---------------------|
| id           | INTEGER PRIMARY KEY |
| subject_name | TEXT                |
| description  | TEXT                |

---

### Table: Questions

| Field        | Type                |
|--------------|---------------------|
| id           | INTEGER PRIMARY KEY |
| subject_id   | INTEGER             |
| meaning      | TEXT                |
| correct_term | TEXT                |

---

### Table: Results

| Field           | Type                |
|-----------------|---------------------|
| id              | INTEGER PRIMARY KEY |
| user_id         | INTEGER             |
| subject_id      | INTEGER             |
| total_questions | INTEGER             |
| correct_answers | INTEGER             |
| score           | INTEGER             |
| date_taken      | TEXT                |

---

## Application Screens

### Splash Screen
Displays application logo during startup.

**Flow:** Splash Screen → Login Screen

---

### Authentication Screens

**Login Screen**
- Fields: Email, Password
- Buttons: Login, Register
- Role routing: `admin` → Admin Dashboard | `user` → Subject List

**Register Screen**
- Fields: Name, Email, Password, Confirm Password
- Role automatically set as `user`

---

## Admin Module

**Admin Dashboard Menu:**
- Add Subject
- Manage Subjects
- Add Meaning Question
- View Questions
- Logout

**Add Subject Screen:** Subject Name, Description, Save Button

**Add Question Screen:** Select Subject, Meaning / Definition, Correct Term, Save Button

**Question List Screen:** Displays all questions with Edit / Delete options

---

## User Module

**Subject Selection Screen:** Displays available subjects (e.g., Biology, Psychology, Computer Science)

**Question Screen:**
```
Meaning: "The process by which plants make their own food."

Answer: [Text Input Field]

[Submit Button]
```

---

## Answer Validation Logic

```
IF user_input == correct_term
    show "Correct"
    increase score
    go to next question
ELSE
    show "Incorrect"
    stay on current question
```

> User **cannot proceed** until the correct answer is entered.

---

## Result Screen

```
Subject: Biology

Total Questions:   10
Correct Answers:    9
Score:             90%
```

**Buttons:** Repeat Quiz | Back to Subjects

---

## Additional System Features

This section describes additional features for both the **Admin** and **User (Student)** sides of the Reviewer Mobile Application.

### Admin Features

#### Category Topic Management

In addition to managing subjects and questions, the Admin can create **Category Topics** within a specific subject.
This feature allows questions to be organized into smaller topics inside a subject.

**Example Structure:**
- **Subject:** Computer Science
- **Category Topics:**
  - Programming Fundamentals
  - Data Structures
  - Algorithms
  - Database Systems

Each **Category Topic** will contain multiple questions.

**Admin Functions:**
- Add Category Topic
- Edit Category Topic
- Delete Category Topic

**Add Category Topic Process:**
1. Admin opens the **Admin Dashboard**.
2. Selects **Add Category Topic**.
3. Chooses the **Subject** where the category topic will belong.
4. Inputs the **Category Topic Name**.
5. Saves the category topic.

### User / Student Features

#### 1. Subject Completion Status

When a user answers **all questions in a subject**, the system will mark that subject as **DONE**.

**Example:**
- Biology — Done
- Psychology — Done
- Computer Science — In Progress

Even if the subject is marked as **Done**, the user may **answer the questions again anytime** to improve their knowledge and score.

#### 2. Learning Progress Tracking

The application will track the student's progress for each subject.
The system will record:
- Total number of questions
- Number of questions answered
- Completion status
- Last activity

**Example Progress Display:**
> **Subject:** Biology  
> **Progress:** 15 / 20 Questions Answered  
> **Status:** In Progress  

Once all questions are answered:
> 20 / 20 Questions Answered  
> **Status:** Completed  

#### 3. Resume Quiz Feature (Pause and Continue)

If the user leaves the quiz before completing all questions, the system will automatically **save their progress**.
This includes situations such as:
- Returning to the home screen
- Closing the application
- Switching subjects

The system will store the following data:
- Current subject
- Current category topic
- Last answered question number
- Current score
- Skipped questions

When the user opens the subject again, the application will allow them to **resume from where they left off**.

**Example:**
*Progress saved at: Question 12 of 30*

When the user returns to the subject, the application shows options to **Resume Quiz** or **Restart Quiz**.

#### 4. Skip Question Feature

During a quiz, if a student does not know the answer to a question, they can choose to **Skip** it.
Skipped questions are temporarily bypassed and will be presented again at the end of the quiz sequence. This allows the student to maintain their momentum and answer the skipped questions later.

---

## Summary of Added Features

**Admin Side:**
- Add Category Topic inside subjects
- Organize questions by topic
- Manage topics for better content structure

**User / Student Side:**
- Subject completion tracking
- Progress monitoring
- Resume unfinished quizzes
- Skip questions feature
- Ability to repeat completed subjects

---

## Project Folder Structure

```
lib/
├── main.dart
├── config/
│   └── database_helper.dart
├── models/
│   ├── user_model.dart
│   ├── subject_model.dart
│   ├── question_model.dart
│   └── result_model.dart
├── services/
│   ├── auth_service.dart
│   ├── question_service.dart
│   └── result_service.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── admin/
│   │   ├── admin_dashboard.dart
│   │   ├── add_subject_screen.dart
│   │   ├── add_question_screen.dart
│   │   └── manage_questions_screen.dart
│   └── user/
│       ├── subject_list_screen.dart
│       ├── question_screen.dart
│       └── result_screen.dart
├── widgets/
│   ├── custom_button.dart
│   ├── question_card.dart
│   └── popup_message.dart
└── utils/
    ├── constants.dart
    └── validators.dart
```

---

## Development Setup

> **Note:** Flutter and Android Studio are already installed. Skip Steps 1 and 2.

**Step 3** — Create Flutter Project
```bash
flutter create reviewer_app
```

**Step 4** — Open Project
```bash
cd reviewer_app
```

**Step 5** — Add Dependencies to `pubspec.yaml`
```yaml
dependencies:
  sqflite: latest
  path: latest
  provider: latest
```

**Step 6** — Setup SQLite Database

Create the database helper file at:
```
lib/config/database_helper.dart
```

---

## Development Phases

| Phase | Description                          |
|-------|--------------------------------------|
| 1     | Project setup and database configuration |
| 2     | User authentication system           |
| 3     | Admin subject and question management |
| 4     | User quiz answering system           |
| 5     | Score and result tracking            |
| 6     | UI improvements and testing          |

---

## Future Improvements

- Timer per question
- Randomized questions
- Difficulty levels
- Leaderboards
- Question images
- Cloud sync database
- Progress tracking

---

## Author

| Field        | Detail                                        |
|--------------|-----------------------------------------------|
| Developer    | Mark Jastin                                   |
| Project Type | Mobile Reviewer Application for College Students |
| Framework    | Flutter                                       |
| Database     | SQLite                                        |
| Platform     | Android                                       |
