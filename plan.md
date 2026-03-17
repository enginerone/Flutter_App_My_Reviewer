Reviewer Mobile Application

Project Overview

Reviewer is an Android mobile application built using Flutter that helps college students review and memorize key academic terms.

The system works using Meaning â†’ Term answering.

Students read a definition or meaning and must type the correct term that matches that meaning.

Example:

Meaning:

"What is the study of living organisms?"

User Answer:

"Biology"

If correct, the user proceeds to the next question.

The questions and answers are created by the Admin and stored in the SQLite local database.

The application works offline and is designed for Android devices only.

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

System Objectives

1\.	Provide a mobile reviewer tool for college students.

2\.	Allow administrators to create subjects and meaning-based questions.

3\.	Allow users to answer questions by typing the correct academic term.

4\.	Provide immediate feedback for correct and incorrect answers.

5\.	Show quiz results and allow users to repeat quizzes.

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Technology Stack

Frontend

Flutter Framework

Language:

Dart

IDE:

Android Studio

Platform:

Android only

Database

SQLite (local database)

Flutter Packages:

â€¢	sqflite

â€¢	path

â€¢	provider

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Application Architecture

Flutter App

|

|

SQLite Local Database

This architecture means:

â€¢	No internet required

â€¢	Fully offline functionality

â€¢	Fast local data retrieval

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

System Roles

1 Admin Role

The admin manages all review content in the application.

Admin Features

Admin Registration and Login

Subject Management

Admin can create subjects such as:

â€¢	Biology

â€¢	Psychology

â€¢	Computer Science

â€¢	Mathematics

Meaning and Term Management

Admin inputs:

Meaning (definition)

Correct Term (answer)

Example:

Meaning:

"The study of the human mind and behavior"

Correct Term:

Psychology

The answer is stored in the database but not shown to the user until the answer is correct.

Admin Functions:

â€¢	Add Subject

â€¢	Edit Subject

â€¢	Delete Subject

â€¢	Add Questions

â€¢	Edit Questions

â€¢	Delete Questions

â€¢	View Question List

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

2 User Role

Users are students who will answer the reviewer questions.

User Features

User Registration

User Login

Select Subject

Example subjects:

Biology

Psychology

Computer Science

Answer Questions

The system displays the meaning.

Example:

Meaning:

"A network that connects computers worldwide."

User Input:

Internet

Answer Validation

If the answer is correct:

âœ” Correct Answer

Display the correct term

Proceed to next question

If incorrect:

âœ– Incorrect Answer

User must try again

Cannot proceed to the next question

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Quiz Completion

After finishing all questions in a subject, the application shows the result.

Example Result:

Subject: Psychology

Total Questions: 20

Correct Answers: 18

Score: 90%

Options:

Repeat Quiz

Back to Subject List

Users may repeat quizzes anytime to improve their scores.

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Database Design

Table: Users

Fields:

id INTEGER PRIMARY KEY

name TEXT

email TEXT

password TEXT

role TEXT

Role values:

admin

user

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Table: Subjects

Fields:

id INTEGER PRIMARY KEY

subject\_name TEXT

description TEXT

Example:

1 Biology

2 Psychology

3 Computer Science

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Table: Questions

Fields:

id INTEGER PRIMARY KEY

subject\_id INTEGER

meaning TEXT

correct\_term TEXT

Example:

Meaning:

"The study of the human mind and behavior"

Correct Term:

Psychology

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Table: Results

Fields:

id INTEGER PRIMARY KEY

user\_id INTEGER

subject\_id INTEGER

total\_questions INTEGER

correct\_answers INTEGER

score INTEGER

date\_taken TEXT

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Application Screens

Splash Screen

Displays application logo during startup.

Flow:

Splash Screen â†’ Login Screen

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Authentication Screens

Login Screen

Fields:

Email

Password

Login Button

Register Button

System checks user role:

Admin â†’ Admin Dashboard

User â†’ Subject List

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Register Screen

Fields:

Name

Email

Password

Confirm Password

Role automatically set as User.

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Admin Module

Admin Dashboard Menu:

Add Subject

Manage Subjects

Add Meaning Question

View Questions

Logout

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Add Subject Screen

Fields:

Subject Name

Description

Save Button

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Add Question Screen

Fields:

Select Subject

Meaning / Definition

Correct Term

Save Button

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Question List Screen

Displays all questions.

Options:

Edit

Delete

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

User Module

Subject Selection Screen

Displays available subjects.

Example:

Biology

Psychology

Computer Science

User selects a subject to begin.

The subject is this following below:

â€¢	Management Information Systems

â€¢	Great Books

â€¢	Information Assurance \& Security (Cybersecurity Fundamentals) 

â€¢	Mobile Systems and Technologies

â€¢	Programming Languages

â€¢	Web Systems and Technologies



\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Question Screen

Displays meaning.

Example:

Meaning:

"The process by which plants make their own food."

Answer:

\[Text Input Field]

Submit Button

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Answer Validation Logic

Pseudo Logic:

IF user\_input == correct\_term

show "Correct"

increase score

go to next question

ELSE

show "Incorrect"

stay on current question

User cannot proceed until correct answer is entered.

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Result Screen

Displays quiz summary.

Example:

Subject: Biology

Total Questions: it can be unlimited

Correct Answers: score/over

Score: %

Buttons:

Repeat Quiz

Back to Subjects

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Project Folder Structure

lib/

main.dart

config/

database\_helper.dart

models/

user\_model.dart

subject\_model.dart

question\_model.dart

result\_model.dart

services/

auth\_service.dart

question\_service.dart

result\_service.dart

screens/

auth/

login\_screen.dart

register\_screen.dart

admin/

admin\_dashboard.dart

add\_subject\_screen.dart

add\_question\_screen.dart

manage\_questions\_screen.dart

user/

subject\_list\_screen.dart

question\_screen.dart

result\_screen.dart

widgets/

custom\_button.dart

question\_card.dart

popup\_message.dart

utils/

constants.dart

validators.dart







________________________________________

Additional System Features

This section describes additional features for both the Admin and User (Student) sides of the Reviewer Mobile Application.

Admin Features

Category Topic Management

In addition to managing subjects and questions, the Admin can create Category Topics within a specific subject.
This feature allows questions to be organized into smaller topics inside a subject.

Example Structure:
Subject: Computer Science
Category Topics:
- Programming Fundamentals
- Data Structures
- Algorithms
- Database Systems

Each Category Topic will contain multiple questions.

Admin Functions:
- Add Category Topic
- Edit Category Topic
- Delete Category Topic

Add Category Topic Process:
1. Admin opens the Admin Dashboard.
2. Selects Add Category Topic.
3. Chooses the Subject where the category topic will belong.
4. Inputs the Category Topic Name.
5. Saves the category topic.

User / Student Features

1. Subject Completion Status

When a user answers all questions in a subject, the system will mark that subject as DONE.

Example:
Biology — Done
Psychology — Done
Computer Science — In Progress

Even if the subject is marked as Done, the user may answer the questions again anytime to improve their knowledge and score.

2. Learning Progress Tracking

The application will track the student's progress for each subject.
The system will record:
- Total number of questions
- Number of questions answered
- Completion status
- Last activity

Example Progress Display:
Subject: Biology
Progress: 15 / 20 Questions Answered
Status: In Progress

Once all questions are answered:
20 / 20 Questions Answered
Status: Completed

3. Resume Quiz Feature (Pause and Continue)

If the user leaves the quiz before completing all questions, the system will automatically save their progress.
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

When the user opens the subject again, the application will allow them to resume from where they left off.

Example:
Progress saved at: Question 12 of 30

When the user returns to the subject, the application shows options to Resume Quiz or Restart Quiz.

4. Skip Question Feature

During a quiz, if a student does not know the answer to a question, they can choose to Skip it.
Skipped questions are temporarily bypassed and will be presented again at the end of the quiz sequence. This allows the student to maintain their momentum and answer the skipped questions later.

Summary of Added Features

Admin Side:
- Add Category Topic inside subjects
- Organize questions by topic
- Manage topics for better content structure

User / Student Side:
- Subject completion tracking
- Progress monitoring
- Resume unfinished quizzes
- Skip questions feature
- Ability to repeat completed subjects

________________________________________
