import SwiftUI

struct AIQuestionQueueView: View {
    @EnvironmentObject private var viewModel: TeachHomeyViewModel
    @StateObject private var questionTriggerService = AIQuestionTriggerService.shared
    private let dataStore = TeachHomeyDataStore.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !questionTriggerService.getUnansweredQuestions().isEmpty {
                HStack {
                    Text("Smart Questions")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(questionTriggerService.getUnansweredQuestions().count) New")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.blue))
                }
                
                VStack(spacing: 16) {
                    ForEach(questionTriggerService.getUnansweredQuestions().prefix(3)) { triggeredQuestion in
                        if let question = dataStore.aiQuestions.first(where: { $0.id == triggeredQuestion.questionId }) {
                            AIQuestionCard(
                                question: question,
                                selectedOption: viewModel.aiQuestionAnswers[question.id],
                                onSelectAnswer: { answer in
                                    viewModel.updateAIAnswer(for: question.id, answer: answer)
                                }
                            )
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    AIQuestionQueueView()
        .environmentObject(TeachHomeyViewModel())
}