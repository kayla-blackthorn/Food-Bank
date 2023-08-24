import { format } from '../helpers';

describe('format()', () => {
    it('should format string', () => {
      expect(format('This is a test {0} string', ['Hello World'])).toBe('This is a test Hello World string');
    });

    it('should format string with multiple dynamic params', () => {
        expect(format('Welcome {0}! My email is {1}', ['Blackthorn','test@bt.com'])).toBe('Welcome Blackthorn! My email is test@bt.com');
      });
});