import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/session_state.dart';
import '../../../models/nomad_user.dart';
import '../widgets/onboarding_scaffold.dart';

class BasicInfoStep extends StatefulWidget {
  const BasicInfoStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  State<BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends State<BasicInfoStep> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    if (_nameController.text.isEmpty && session.onboarding.name.isNotEmpty) {
      _nameController.text = session.onboarding.name;
    }

    return OnboardingScaffold(
      title: 'Basic info',
      subtitle: 'Just enough to show the right dots around you.',
      primaryActionText: 'Continue',
      onPrimaryAction: () {
        final age = int.tryParse(_ageController.text.trim());
        session.updateOnboarding((o) {
          o.name = _nameController.text.trim();
          o.age = age;
        });
        widget.onNext();
      },
      child: ListView(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Age',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: session.onboarding.gender.isEmpty ? null : session.onboarding.gender,
            decoration: const InputDecoration(
              labelText: 'Gender',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'Female', child: Text('Female')),
              DropdownMenuItem(value: 'Male', child: Text('Male')),
              DropdownMenuItem(value: 'Non-binary', child: Text('Non-binary')),
              DropdownMenuItem(value: 'Prefer not to say', child: Text('Prefer not to say')),
            ],
            onChanged: (value) {
              if (value == null) return;
              session.updateOnboarding((o) => o.gender = value);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: session.onboarding.vanType.isEmpty ? null : session.onboarding.vanType,
            decoration: const InputDecoration(
              labelText: 'Van type',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'Sprinter', child: Text('Sprinter')),
              DropdownMenuItem(value: 'Transit', child: Text('Transit')),
              DropdownMenuItem(value: 'School Bus', child: Text('School Bus')),
              DropdownMenuItem(value: 'Truck Camper', child: Text('Truck Camper')),
              DropdownMenuItem(value: 'Other', child: Text('Other')),
            ],
            onChanged: (value) {
              if (value == null) return;
              session.updateOnboarding((o) => o.vanType = value);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: session.onboarding.travelingWith.isEmpty
                ? null
                : session.onboarding.travelingWith,
            decoration: const InputDecoration(
              labelText: 'Traveling with',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'Solo', child: Text('Solo')),
              DropdownMenuItem(value: 'Partner', child: Text('Partner')),
              DropdownMenuItem(value: 'Pet', child: Text('Pet')),
              DropdownMenuItem(value: 'Family', child: Text('Family')),
              DropdownMenuItem(value: 'Friends', child: Text('Friends')),
            ],
            onChanged: (value) {
              if (value == null) return;
              session.updateOnboarding((o) => o.travelingWith = value);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<LookingFor>(
            value: session.onboarding.lookingFor,
            decoration: const InputDecoration(
              labelText: 'Looking for',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: LookingFor.dating, child: Text('Dating')),
              DropdownMenuItem(value: LookingFor.friends, child: Text('Friends')),
              DropdownMenuItem(value: LookingFor.both, child: Text('Both')),
            ],
            onChanged: (value) {
              if (value == null) return;
              session.updateOnboarding((o) => o.lookingFor = value);
            },
          ),
        ],
      ),
    );
  }
}
