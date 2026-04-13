import 'package:flutter/material.dart';

import '../../../domain/models/inference/inference_models.dart';

class ModelSelector extends StatelessWidget {
  const ModelSelector({
    super.key,
    required this.selectedModel,
    required this.isModelLoading,
    required this.onModelChanged,
  });

  final ModelType selectedModel;
  final bool isModelLoading;
  final ValueChanged<ModelType> onModelChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ModelType.values.map((model) {
          final isSelected = selectedModel == model;
          return GestureDetector(
            onTap: () {
              if (!isModelLoading && model != selectedModel) {
                onModelChanged(model);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                model.name.toUpperCase(),
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
