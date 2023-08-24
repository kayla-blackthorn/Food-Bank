import { createElement } from "lwc";
import BaseAdmin from "c/baseAdmin";
import getInitData from "@salesforce/apex/AdminPageController.getInitData";
import packageAuth from "@salesforce/apex/AdminPageController.blackthornAuth";
import addPermission from "@salesforce/apex/AdminPageController.assignPermissionSetToLoggedinUser";

// Mocking imperative Apex method call
jest.mock(
    '@salesforce/apex/AdminPageController.getInitData',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);
jest.mock(
    '@salesforce/apex/AdminPageController.blackthornAuth',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/AdminPageController.assignPermissionSetToLoggedinUser',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

// Sample data for imperative Apex call
const AUTH_DONE = {
        isSysAdmin: true,
        isAuthorized: true,
        authTime: '6 Jan'
};


const AUTH_NOT_DONE = {
    isSysAdmin: true,
    isAuthorized: false,
    authTime: '6 Jan'
};

const USER_NOT_ADMIN = {
    isSysAdmin: false,
    isAuthorized: false,
    authTime: '6 Jan'
};

// Sample error for imperative Apex call
const ERROR_RESPONSE = {
    body: { message: 'An internal server error has occurred' },
    ok: false,
    status: 400,
    statusText: 'Bad Request'
};

describe("c-base-admin", () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Prevent data saved on mocks from leaking between tests
        jest.clearAllMocks();
    });

    // Helper function to wait until the microtask queue is empty. This is needed for promise
    // timing when calling imperative Apex.
    async function flushPromises() {
        return Promise.resolve();
    }

    it('register and trigger init method expect authorized response', async () => {

        getInitData.mockResolvedValue(AUTH_DONE);

        // Create initial element
        const element = createElement('c-base-admin', {
            is: BaseAdmin
        });

        document.body.appendChild(element);
        await flushPromises();
        
        const authMessageContainer = element.shadowRoot.querySelector('p.admin-message-section');
        expect(authMessageContainer.textContent).toContain('c.Message_Org_Authorized'); //message defined by this label
    });

    it('register and trigger init method expect not authorized response', async () => {
        getInitData.mockResolvedValue(AUTH_NOT_DONE);
        // Create initial element
        const element = createElement('c-base-admin', {
            is: BaseAdmin
        });
        document.body.appendChild(element);
        await flushPromises();
        const authMessageContainer = element.shadowRoot.querySelector('p.admin-message-section');
        expect(authMessageContainer.textContent).toContain('c.Message_Authorize_Info'); //message defined by this label
        
    });

    it('register and trigger init method expect not not system admin response', async () => {
        getInitData.mockResolvedValue(USER_NOT_ADMIN);
        // Create initial element
        const element = createElement('c-base-admin', {
            is: BaseAdmin
        });
        document.body.appendChild(element);
        await flushPromises();
        const authMessageContainer = element.shadowRoot.querySelector('p.admin-message-section');
        expect(authMessageContainer.textContent).toContain('c.Error_Not_SystemAdmin'); //message defined by this label
        
    });

    it('register and trigger init method expect error response', async () => {
        getInitData.mockResolvedValue(ERROR_RESPONSE);
        // Create initial element
        const element = createElement('c-base-admin', {
            is: BaseAdmin
        });
        document.body.appendChild(element);
        await flushPromises();
        const authMessageContainer = element.shadowRoot.querySelector('p.admin-message-section');
        expect(authMessageContainer.textContent).toContain('c.Error_Not_SystemAdmin'); //message defined by this label
    });

    it('register and trigger init method expect auth url generated', async () => {
        getInitData.mockResolvedValue(AUTH_DONE);
        packageAuth.mockResolvedValue('https://google.com');
        // Create initial element
        const element = createElement('c-base-admins', {
            is: BaseAdmin
        });
        document.body.appendChild(element);
        await flushPromises();
        // Select button for executing Apex call
        const buttonEl = element.shadowRoot.querySelector('.authBtn');
        buttonEl.click();
       
        await flushPromises();
    });

    it('register and trigger init method show permission set assignment button', async () => {
        getInitData.mockResolvedValue(USER_NOT_ADMIN);
        // Create initial element
        const element = createElement('c-base-admin', {
            is: BaseAdmin
        });
        document.body.appendChild(element);
        await flushPromises();
        // Select button for executing Apex call
        const buttonEl = element.shadowRoot.querySelector('.permissionBtn');
        expect(buttonEl != undefined).toBe(true);

    });

    it('permission set assignment called to execute', async () => {
        getInitData.mockResolvedValue(USER_NOT_ADMIN);
        // Create initial element
        const element = createElement('c-base-admin', {
            is: BaseAdmin
        });
        document.body.appendChild(element);
        await flushPromises();

        // Select button for executing Apex call
        const buttonEl = element.shadowRoot.querySelector('.permissionBtn');
        expect(buttonEl != undefined).toBe(true);
        jest.clearAllMocks();
        addPermission.mockResolvedValue(true);
        getInitData.mockResolvedValue(AUTH_NOT_DONE);
        
        buttonEl.click();
      
    });

});
