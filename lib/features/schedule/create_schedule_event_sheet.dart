import 'package:flutter/material.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/theme/app_colors.dart';

class CreateScheduleEventSheet extends StatefulWidget {
  const CreateScheduleEventSheet({super.key, required this.initialDate});

  final DateTime initialDate;

  static Future<UserScheduleEvent?> show(
    BuildContext context, {
    required DateTime initialDate,
  }) {
    return showModalBottomSheet<UserScheduleEvent>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateScheduleEventSheet(initialDate: initialDate),
    );
  }

  @override
  State<CreateScheduleEventSheet> createState() =>
      _CreateScheduleEventSheetState();
}

class _CreateScheduleEventSheetState extends State<CreateScheduleEventSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _locationController = TextEditingController();
  final _badgeController = TextEditingController();
  final List<_FuelingHintControllers> _fuelingHintControllers = [];

  ScheduleEventType _type = ScheduleEventType.training;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  Future<UserProfile?>? _profileFuture;
  UserProfile? _profile;
  String? _error;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateUtils.dateOnly(widget.initialDate);
    _selectedTime = _nextHour(TimeOfDay.now());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = UserScope.of(context);
    _profileFuture ??= scope.repository.getProfile(scope.uid);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _locationController.dispose();
    _badgeController.dispose();
    for (final controllers in _fuelingHintControllers) {
      controllers.dispose();
    }
    super.dispose();
  }

  TimeOfDay _nextHour(TimeOfDay time) {
    final hour = time.minute == 0 ? time.hour : time.hour + 1;
    return TimeOfDay(hour: hour % 24, minute: 0);
  }

  String? _requiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked == null || !mounted) return;
    setState(() => _selectedDate = DateUtils.dateOnly(picked));
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked == null || !mounted) return;
    setState(() => _selectedTime = picked);
  }

  void _addFuelingHint() {
    setState(() => _fuelingHintControllers.add(_FuelingHintControllers()));
  }

  void _removeFuelingHint(_FuelingHintControllers controllers) {
    setState(() => _fuelingHintControllers.remove(controllers));
    controllers.dispose();
  }

  Future<void> _submit() async {
    if (_isSaving || _profile == null) {
      return;
    }

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    final scope = UserScope.of(context);
    final profile = _profile!;
    final startAt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    ).toUtc();
    final fuelingHints = _fuelingHintControllers
        .map(
          (controllers) => FuelingHint(
            timing: controllers.timing.text.trim(),
            label: controllers.label.text.trim(),
          ),
        )
        .where((hint) => hint.timing.isNotEmpty || hint.label.isNotEmpty)
        .toList(growable: false);

    final event = UserScheduleEvent(
      eventId: 'schedule_${DateTime.now().microsecondsSinceEpoch}',
      type: _type,
      startAt: startAt,
      title: _titleController.text.trim(),
      subtitle: _emptyToNull(_subtitleController.text),
      location: _emptyToNull(_locationController.text),
      badge: _type == ScheduleEventType.match
          ? _emptyToNull(_badgeController.text)
          : null,
      fuelingHints: fuelingHints,
    );

    try {
      await scope.repository.saveProfile(
        profile.copyWith(scheduleEvents: [...profile.scheduleEvents, event]),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Event created')));
      Navigator.of(context).pop(event);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to create event: $error';
        _isSaving = false;
      });
    }
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: FutureBuilder<UserProfile?>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              _profile = snapshot.data;
            }

            final isLoadingProfile =
                snapshot.connectionState != ConnectionState.done;
            final profileError =
                !isLoadingProfile &&
                    (snapshot.hasError || snapshot.data == null)
                ? 'Unable to load your profile. Try again in a moment.'
                : null;

            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF151515),
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                border: Border(top: BorderSide(color: Color(0xFF303030))),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 22 + bottomPadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 48,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Create Schedule Event',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Close',
                            visualDensity: VisualDensity.compact,
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Color(0xFFD7D7D7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _EventTypeRow(
                        type: _type,
                        enabled: !_isSaving,
                        onChanged: (type) => setState(() => _type = type),
                      ),
                      const SizedBox(height: 8),
                      _CompactTextField(
                        icon: Icons.text_fields_rounded,
                        label: 'Title',
                        hintText: 'Add title',
                        controller: _titleController,
                        validator: _requiredText,
                      ),
                      const SizedBox(height: 8),
                      _CompactActionRow(
                        icon: Icons.calendar_month_rounded,
                        label: 'Date',
                        value: _formatDate(_selectedDate),
                        trailingIcon: Icons.calendar_today_rounded,
                        onTap: _isSaving ? null : _pickDate,
                      ),
                      const SizedBox(height: 8),
                      _CompactActionRow(
                        icon: Icons.schedule_rounded,
                        label: 'Time',
                        value: _selectedTime.format(context),
                        trailingIcon: Icons.chevron_right_rounded,
                        onTap: _isSaving ? null : _pickTime,
                      ),
                      const SizedBox(height: 8),
                      _CompactTextField(
                        icon: Icons.notes_rounded,
                        label: 'Subtitle',
                        hintText: 'Add subtitle',
                        controller: _subtitleController,
                      ),
                      const SizedBox(height: 8),
                      _CompactTextField(
                        icon: Icons.location_on_rounded,
                        label: 'Location',
                        hintText: 'Add location',
                        controller: _locationController,
                      ),
                      if (_type == ScheduleEventType.match) ...[
                        const SizedBox(height: 8),
                        _CompactTextField(
                          icon: Icons.emoji_events_rounded,
                          label: 'Badge',
                          hintText: 'Add badge',
                          controller: _badgeController,
                        ),
                      ],
                      const SizedBox(height: 8),
                      _CompactActionRow(
                        icon: Icons.local_fire_department_rounded,
                        label: 'Fueling hints',
                        value: _fuelingHintControllers.isEmpty
                            ? 'Add hints'
                            : '${_fuelingHintControllers.length} hint${_fuelingHintControllers.length == 1 ? '' : 's'}',
                        trailingIcon: Icons.add_rounded,
                        onTap: _isSaving ? null : _addFuelingHint,
                      ),
                      for (final controllers in _fuelingHintControllers) ...[
                        const SizedBox(height: 8),
                        _FuelingHintRow(
                          controllers: controllers,
                          onRemove: () => _removeFuelingHint(controllers),
                        ),
                      ],
                      if (profileError != null || _error != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          _error ?? profileError!,
                          style: const TextStyle(color: AppColors.orange),
                        ),
                      ],
                      const SizedBox(height: 22),
                      FilledButton(
                        onPressed:
                            isLoadingProfile ||
                                profileError != null ||
                                _isSaving
                            ? null
                            : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFE7E7E7),
                          foregroundColor: Colors.black,
                          disabledBackgroundColor: const Color(0xFF555555),
                          disabledForegroundColor: const Color(0xFFBDBDBD),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: isLoadingProfile || _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Text(
                                'Save',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _FuelingHintControllers {
  final timing = TextEditingController();
  final label = TextEditingController();

  void dispose() {
    timing.dispose();
    label.dispose();
  }
}

class _FuelingHintRow extends StatelessWidget {
  const _FuelingHintRow({required this.controllers, required this.onRemove});

  final _FuelingHintControllers controllers;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _CompactTextField(
            icon: Icons.timer_rounded,
            label: 'Timing',
            hintText: '2H before',
            controller: controllers.timing,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _CompactTextField(
            icon: Icons.restaurant_rounded,
            label: 'Hint',
            hintText: 'Hydrate',
            controller: controllers.label,
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          tooltip: 'Remove hint',
          onPressed: onRemove,
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }
}

class _EventTypeRow extends StatelessWidget {
  const _EventTypeRow({
    required this.type,
    required this.enabled,
    required this.onChanged,
  });

  final ScheduleEventType type;
  final bool enabled;
  final ValueChanged<ScheduleEventType> onChanged;

  @override
  Widget build(BuildContext context) {
    return _CompactShell(
      icon: Icons.event_note_rounded,
      label: 'Event type',
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ScheduleEventType>(
          value: type,
          dropdownColor: const Color(0xFF252525),
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFFD5D5D5),
            size: 18,
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          selectedItemBuilder: (context) {
            return ScheduleEventType.values.map((type) {
              return Align(
                alignment: Alignment.centerRight,
                child: Text(_labelFor(type)),
              );
            }).toList();
          },
          items: ScheduleEventType.values.map((type) {
            return DropdownMenuItem(value: type, child: Text(_labelFor(type)));
          }).toList(),
          onChanged: enabled
              ? (type) {
                  if (type != null) {
                    onChanged(type);
                  }
                }
              : null,
        ),
      ),
    );
  }

  String _labelFor(ScheduleEventType type) {
    switch (type) {
      case ScheduleEventType.meal:
        return 'Meal';
      case ScheduleEventType.training:
        return 'Training';
      case ScheduleEventType.match:
        return 'Match';
    }
  }
}

class _CompactTextField extends StatelessWidget {
  const _CompactTextField({
    required this.icon,
    required this.label,
    required this.hintText,
    required this.controller,
    this.validator,
  });

  final IconData icon;
  final String label;
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return _CompactShell(
      icon: icon,
      label: label,
      child: TextFormField(
        controller: controller,
        validator: validator,
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF8F8F8F),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
          errorStyle: const TextStyle(height: 0.7),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _CompactActionRow extends StatelessWidget {
  const _CompactActionRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.trailingIcon,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final IconData trailingIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: _CompactShell(
        icon: icon,
        label: label,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFDADADA),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 7),
            Icon(trailingIcon, size: 16, color: const Color(0xFFBDBDBD)),
          ],
        ),
      ),
    );
  }
}

class _CompactShell extends StatelessWidget {
  const _CompactShell({
    required this.icon,
    required this.label,
    required this.child,
  });

  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3A3A3A)),
      ),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(icon, color: const Color(0xFFD8D8D8), size: 13),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFD8D8D8),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}
