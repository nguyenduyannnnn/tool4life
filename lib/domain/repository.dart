import 'package:flutter/material.dart';

import '../data/models/request/login_request_model.dart';
import '../data/network/api/api.dart';
import 'interaction/interaction.dart';

class Repository {
  static login(BuildContext context, LoginRequestModel model, bool showError) =>
      Interaction(
              context: context,
              url: API.login(),
              param: model.toJson(),
              showError: showError)
          .post();
}
