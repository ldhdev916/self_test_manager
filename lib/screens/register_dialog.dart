import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:self_test_manager/api/api_data.dart';

class RegisterDialog extends GetResponsiveView {
  final Future<void> Function(SurveyData) onRegister;

  RegisterDialog({Key? key, required this.onRegister}) : super(key: key);

  final _surveyData = const SurveyData().obs;

  @override
  Widget builder() {
    return SizedBox(
        height: screen.height * 0.4,
        child: Obx(() =>
            Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              QuestionRow(
                  value: _surveyData.value.suspicious,
                  question: "학생 본인이 코로나19 감염에 의심되는 임상증상이 있나요?",
                  onChanged: (value) => _surveyData(
                      _surveyData.value.copyWith(suspicious: value))),
              DropdownButtonFormField<QuickTestResult>(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "학생은 오늘(어제 저녁 포함) 신속항원검사(자가진단)를 실시했나요?"),
                  value: _surveyData.value.quickTest,
                  items: const [
                    DropdownMenuItem(
                        value: QuickTestResult.none, child: Text("검사하지 않음")),
                    DropdownMenuItem(
                        value: QuickTestResult.negative, child: Text("음성")),
                    DropdownMenuItem(
                        value: QuickTestResult.positive, child: Text("양성"))
                  ],
                  onChanged: (value) => _surveyData(
                      _surveyData.value.copyWith(quickTest: value))),
              QuestionRow(
                  value: _surveyData.value.waitingResult,
                  question: "학생 본인이 PCR등 검사를 받고 그 결과를 기다리고 있나요?",
                  onChanged: (value) => _surveyData(
                      _surveyData.value.copyWith(waitingResult: value))),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(
                    onPressed: () {
                      onRegister(_surveyData.value);
                      Get.back();
                    },
                    child: const Text("제출"))
              ])
            ])));
  }
}

class QuestionRow extends StatelessWidget {
  final String question;
  final ValueChanged<bool> onChanged;
  final bool value;

  const QuestionRow(
      {Key? key,
      required this.value,
      required this.question,
      required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Flexible(child: Text(question)),
      Checkbox(
          value: value,
          onChanged: (value) {
            if (value == null) return;
            onChanged(value);
          })
    ]);
  }
}
