import { LightningElement } from "lwc";
import packageAuth from "@salesforce/apex/AdminPageController.blackthornAuth";
import getInitData from "@salesforce/apex/AdminPageController.getInitData";
import addPermission from "@salesforce/apex/AdminPageController.assignPermissionSetToLoggedinUser";
import authorizeApp from "@salesforce/label/c.Btn_Authorize_the_App";
import assignPermissionSetBtn from "@salesforce/label/c.Btn_Assign_PermissionSet";
import btAdminTitle from "@salesforce/label/c.Label_Admin_Title";
import configTabset from "@salesforce/label/c.Label_Configuration_Tabset";
import messageAuthorizeInfo from "@salesforce/label/c.Message_Authorize_Info";
import messageErrorSysAdmin from "@salesforce/label/c.Error_Not_SystemAdmin";
import orgAuthorized from "@salesforce/label/c.Message_Org_Authorized";
import {format,reduceErrors} from 'c/helpers'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class BaseAdmin extends LightningElement {
    showSpinner;
    isSysAdmin;
    isLightningContext;
    authTime;

    label = { authorizeApp, btAdminTitle, configTabset, messageErrorSysAdmin, messageAuthorizeInfo, orgAuthorized,assignPermissionSetBtn };

    connectedCallback() {
        this.doInit(); 
    }

    doInit () {
        this.showSpinner = true;
        getInitData()
            .then((result) => {
                console.log('result ='+result);
                if (result) {
                    console.log(result.isSysAdmin);
                    this.isSysAdmin = result.isSysAdmin;
                    this.isAuthorized = result.isAuthorized;
                    this.authTime = result.authTime;
                } else {
                    this.isSysAdmin = false;
                }
            })
            .catch((error) => {
                this.isSysAdmin = false;
            })
            .finally(() => {
                this.showSpinner = false;
            });    
    }

    authorizeByOAuth (event) {
        this.showSpinner = true;
        packageAuth()
            .then((result) => {
                window.location = result;
            })
            .catch((error) => {
                this.showError( reduceErrors(error).join(',') );    
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    get authMessage () {
        if (this.isAuthorized) {
            return format(orgAuthorized,[this.authTimeStamp]);
        }
        return messageAuthorizeInfo;
    }

    assignPermissionSet () {
        this.showSpinner = true;  
        addPermission()
            .then((result) => {
                doInit();     
            })
            .catch((error) => {
                //we have an error show it on front end
                this.showError( reduceErrors(error).join(',') );
            })
            .finally(() => {
                this.showSpinner = false;
            });  
    }

    showError (message) {
        const event = new ShowToastEvent({
            title: 'Error',
            message: message,
        });
        this.dispatchEvent(event);
    }
   
}
