const functions = require("firebase-functions");
const admin = require("firebase-admin");
// To avoid deployment errors, do not call admin.initializeApp() in your code

exports.createCustomToken = functions
  .region("asia-northeast3")
  .https.onRequest(async (request, response) => {
    // ff 의 Deploy 안되는 이슈를 해결하기 위해 onData 를 onRequest 형식으로 변경했습니다.
    
    let data = request.body.data;

    functions.logger.log(`# cors with header`);

    response.set("Access-Control-Allow-Origin", "*"); // 모든 도메인에서의 요청을 허용
    response.set("Access-Control-Allow-Methods", "GET, POST"); // 허용된 메소드

    functions.logger.log(
      `# createUser request: ${JSON.stringify(request.body)}`,
    );

    let user = data.user;
    try {
      await admin.auth().createUser(user);
      functions.logger.log(`# createUser success ${user.uid}`);
    } catch (e) {
      functions.logger.log(`# createUser failed ${user.uid}`);
      await admin.auth().updateUser(user.uid, user);
      functions.logger.log(`# updateUser success ${user.uid}`);
    }

    let token = await admin.auth().createCustomToken(user.uid);
    let result = { data: { token } };
    functions.logger.log(`# result ${JSON.stringify(result)}`);

    response.send(result);
  });
