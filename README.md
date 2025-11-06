# Room Management for Hospital

CADT, IDT, CS, SE, GEN-10, G4<br>
Supervised by Ronan OGOR, Leturer & Researcher at CADT<br>
By LIM Ieangzorng & Tong Vorak

To run: 'dart run'
To test: 'dart test'

## Project Description

The Hospital Room Management System is a console-based application built using Dart to help hospital administrators efficiently manage patient rooms and related operations. The system focuses on improving room utilization, streamlining admissions and discharges, automating room status updates, and ensuring transparent cost tracking—all within a lightweight terminal interface.

The system allows users to register and categorize rooms based on their type (general, private, ICU, etc.), assign patients to available rooms or beds, and update room status automatically when patients are admitted, transferred, or discharged. Integration between the admission and discharge modules ensures that room availability reflects real-time hospital conditions.

A built-in housekeeping and maintenance feature enables staff to mark rooms for cleaning or repair, ensuring that only ready rooms can be assigned to new patients. The billing module automatically calculates charges based on room type and duration of stay, simplifying the financial process. Additionally, role-based access control ensures that different users—such as administrators, receptionists, and housekeeping staff—can only access functions relevant to their responsibilities.

This project demonstrates fundamental object-oriented programming concepts in Dart, including classes, encapsulation, and data modeling, while simulating real-world hospital operations in a simple and interactive console environment.

## Key Features

1.	Room Information Management – Register rooms, define room types, track capacity and status.
2.	Patient Room Allocation – Assign or transfer patients to rooms and manage occupancy.
3.	Admission and Discharge Integration – Automatically update room availability when patients are admitted or discharged.
4.	Housekeeping and Maintenance – Mark rooms for cleaning or maintenance and prevent premature reassignment.
5.	Billing and Cost Management – Calculate charges based on room type and stay duration.
6.	User Roles and Permissions – Restrict access by role (Admin, Receptionist, Housekeeping).

## Test Flows

The test suite begins by verifying that the hospital dataset loads correctly from disk, ensuring rooms, patients, and stays are present and well-formed. It then exercises the admission workflow under normal and exceptional conditions. For a successful admission, a female patient who is not currently assigned is admitted into a female-only ward that has at least one available bed; after the call to admit, the patient’s status transitions to assigned, one ward bed flips from available to occupied, and a new active stay exists for that patient. Next, the suite validates that admissions fail when preconditions are violated: attempting to admit into a full room (all beds occupied) throws an exception, attempting to admit into a room temporarily placed under maintenance also throws, and attempting to admit a patient whose gender conflicts with the room’s gender policy is rejected. The discharge flow is tested end to end by picking an active stay, confirming the pre-state (stay is active, bed is occupied), running the discharge function by stay ID, and asserting the post-state across all affected entities: the stay becomes inactive with a discharge timestamp, the bed transitions to needCleaning rather than available, the patient’s status becomes discharged, and the room’s computed overallStatus reflects “Needs Cleaning” because it now contains at least one bed requiring cleaning. Finally, the suite confirms billing from snapshots on already-discharged stays, using deterministic time ranges in the dataset: a shared-room stay of less than twenty-four hours is billed at the minimum one-day rate of $60.00, while a private-room stay of roughly twenty-two hours is billed at the minimum one-day rate of $200.00. Across these tests, lookups consistently use the hospital’s indexed accessors getPatientById and getBedById, enum comparisons enforce the intended state machine for PatientStatus and BedAvailability, and the logic verifies that snapshot fields captured at admission (room type and optional ICU acuity) are sufficient for accurate post-discharge billing.

## Technologies Used

- Programming Language: Dart
- Environment: Console (CLI-based interaction)
- Concepts Applied: Object-Oriented Programming (OOP), Collections, File I/O (optional), Basic Error Handling