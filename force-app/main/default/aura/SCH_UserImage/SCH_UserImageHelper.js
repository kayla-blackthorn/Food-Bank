({
    userMap: {},
    getUserHelper: function (cmp, evt, hlpr) {
        let userId = cmp.get('v.userId');
        if (hlpr.checkUserId(cmp, hlpr, userId)) {
            return;
        }
        var action = cmp.get('c.getUser');
        action.setParams({
            userId: userId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (cmp.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                var div = cmp.find("avatar");
                var body = div.get("v.body");
                cmp.set('v.avtar', result);
                let usersMap = cmp.get('v.usersMap');
                if (!usersMap) {
                    usersMap = {};
                }
                usersMap[userId] = result;
                hlpr.userMap[userId] = result;
                cmp.set('v.usersMap', usersMap);
            } else if (cmp.isValid() && state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('Error message: ' + errors[0].message);
                    }
                } else {
                    console.log('Unknown error');
                }
            }
        });
        $A.enqueueAction(action);
    },
    checkUserId: function (cmp, hlpr, userId) {
        if (hlpr.userMap[userId]) {
            cmp.set('v.avtar', hlpr.userMap[userId]);
            return true;
        } else {
            let usersMap = cmp.get('v.usersMap');
            if (usersMap && usersMap[userId]) {
                hlpr.userMap[userId] = usersMap[userId];
                cmp.set('v.avtar', usersMap[userId]);
                return true;
            }
        }
        return false;
    }
})