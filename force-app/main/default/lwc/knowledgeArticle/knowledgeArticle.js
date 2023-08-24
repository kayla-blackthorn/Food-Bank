import { LightningElement, api, track } from 'lwc';

import SCH_KA_Common_Help_Text from '@salesforce/label/c.SCH_KA_Common_Help_Text';
export default class KnowledgeArticle extends LightningElement {
    @api
    helpText;
    @api
    linkURL;
    @api
    className;
    @api
    iconName = 'utility:new_window';
    @api
    alternativeText = 'Knowledge Article Link';
    
    get displayHelpText(){
        return this.linkURL && this.helpTextIcon ? true : false;
    }
    get helpTextContent(){
        return this.helpText ? this.helpText : SCH_KA_Common_Help_Text;
    }
    get helpTextClass(){
        return 'slds-p-left_xx-small '+ (this.className ? this.className : '');
    }
    get helpTextIcon(){
        return this.iconName ? this.iconName : '';
    }
}