declare module 'lightning/platformShowToastEvent' {
    export class ShowToastEvent extends Event {
        constructor(options: {
            title: string;
            message?: string;
            messageData?: (string | { url: string; label: string })[];
            variant?: 'info'| 'success' | 'warning' | 'error';
            mode?: 'dismissible' | 'pester' | 'sticky';
        });
    }
}
