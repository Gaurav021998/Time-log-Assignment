import { LightningElement, track } from 'lwc';
import saveTimeLog from '@salesforce/apex/TimeTrackingController.saveTimeLog';
import getProjects from '@salesforce/apex/TimeTrackingController.getProjects';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class timeLogForm extends LightningElement {
    @track selectedProject;
    @track logDate;
    @track hoursWorked;
    @track errorMessage;
    @track successMessage;
    @track projectOptions = [];

    // I have Fetch projects when the component is initialized
    connectedCallback() {
        this.loadProjects();
    }

    // Load projects from the Apex method
    loadProjects() {
        getProjects()
            .then((result) => {
                this.projectOptions = result.map((project) => ({
                    label: project.Name,
                    value: project.Id
                }));
            })
            .catch((error) => {
                this.errorMessage = 'Error loading projects.';
            });
    }

    // Handle project selection change when user will select project
    handleProjectChange(event) {
        this.selectedProject = event.target.value;
    }

    // Handle date input change
    handleDateChange(event) {
        this.logDate = event.target.value;
    }

    // Handle hours input change
    handleHoursChange(event) {
        this.hoursWorked = event.target.value;
    }

    // Handle form submission
    handleSubmit() {
        // Validate if all fields are filled in
        if (!this.selectedProject || !this.logDate || !this.hoursWorked) {
            this.errorMessage = 'All fields are required!';
            this.successMessage = '';
            return;
        }

        // Validate hours input to ensure it’s between 0 and 8
        if (this.hoursWorked < 0 || this.hoursWorked > 8) {
            this.errorMessage = 'Hours must be between 0 and 8.';
            this.successMessage = '';
            return;
        }

        // Call the Apex method to save the time log
        saveTimeLog({
            projectId: this.selectedProject,
            logDate: this.logDate,
            hoursWorked: this.hoursWorked
        })
            .then(() => {
                this.errorMessage = '';
                this.successMessage = 'Time log saved successfully!';
                this.showToast('Success', 'Time log saved successfully!', 'success');
            })
            .catch((error) => {
                this.errorMessage = 'Error saving time log: ' + error.body.message;
                this.successMessage = '';
                this.showToast('Error', 'Error saving time log: ' + error.body.message, 'error');
            });
    }

    // Show toast message for success/error
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}