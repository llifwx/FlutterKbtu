import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/workshop.dart';
import '../utils/format.dart';

class WorkshopForm extends StatefulWidget {
  const WorkshopForm({super.key, this.initial});
  final Workshop? initial;

  @override
  State<WorkshopForm> createState() => _WorkshopFormState();
}

class _WorkshopFormState extends State<WorkshopForm> {
  final _key = GlobalKey<FormState>();
  late final Workshop _original;
  late final TextEditingController _title;
  late final TextEditingController _location;
  late final TextEditingController _capacity;
  late final TextEditingController _description;
  final _dateText = TextEditingController();
  final _timeText = TextEditingController();
  final _titleFocus = FocusNode();
  final _locationFocus = FocusNode();
  final _capacityFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _dateFocus = FocusNode();
  final _timeFocus = FocusNode();
  DateTime? _date;
  TimeOfDay? _time;
  WorkshopCategory? _category;
  bool _online = false;
  bool _saving = false;
  bool _allowPop = false;
  bool _askingDiscard = false;
  late final Object _openedValues;

  Object get _values => (
    _title.text,
    _location.text,
    _capacity.text,
    _description.text,
    _date,
    _time,
    _category,
    _online,
  );
  bool get _dirty => _values != _openedValues;
  DateTime? get _combined => switch ((_date, _time)) {
    (final date?, final time?) => DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    ),
    _ => null,
  };

  List<TextEditingController> get _controllers => [
    _title,
    _location,
    _capacity,
    _description,
    _dateText,
    _timeText,
  ];

  @override
  void initState() {
    super.initState();
    _original = widget.initial ?? Workshop.empty();
    _title = TextEditingController(text: _original.title);
    _location = TextEditingController(text: _original.location);
    _capacity = TextEditingController(text: '${_original.capacity}');
    _description = TextEditingController(text: _original.description ?? '');
    _category = _original.category;
    _online = _original.online;
    if (widget.initial != null) {
      _date = DateUtils.dateOnly(_original.startsAt);
      _time = TimeOfDay.fromDateTime(_original.startsAt);
      _dateText.text = formatDate(_original.startsAt);
      _timeText.text = formatTime(_original.startsAt);
    }
    _openedValues = _values;
    for (final controller in _controllers) {
      controller.addListener(_changed);
    }
  }

  void _changed() => setState(() {});

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.removeListener(_changed);
      controller.dispose();
    }
    for (final node in [
      _titleFocus,
      _locationFocus,
      _capacityFocus,
      _descriptionFocus,
      _dateFocus,
      _timeFocus,
    ]) {
      node.dispose();
    }
    super.dispose();
  }

  String? _validateTitle(String? value) {
    final length = (value ?? '').trim().length;
    return length < 3 || length > 60 ? 'Use 3–60 characters' : null;
  }

  String? _validateLocation(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return _online ? 'Enter a workshop link' : 'Enter a campus location';
    }
    return _online && !text.contains('://')
        ? 'Include a protocol, for example https://'
        : null;
  }

  String? _validateCapacity(String? value) {
    final number = int.tryParse((value ?? '').trim());
    if (number == null || number < 1 || number > 500) {
      return 'Enter a whole number from 1 to 500';
    }
    return number < _original.count
        ? 'Cannot be below ${_original.count} registered makers'
        : null;
  }

  String? _validateSchedule(bool isDate) {
    if (isDate && _date == null) return 'Choose a date';
    if (!isDate && _time == null) return 'Choose a time';
    final dateTime = _combined;
    return widget.initial == null &&
            dateTime != null &&
            !dateTime.isAfter(DateTime.now())
        ? 'Choose a future date and time'
        : null;
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date ?? _original.startsAt,
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 10, 12, 31),
    );
    if (!mounted || selected == null) return;
    setState(() => _date = selected);
    _dateText.text = formatDate(selected);
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.fromDateTime(_original.startsAt),
    );
    if (!mounted || selected == null) return;
    setState(() => _time = selected);
    _timeText.text =
        '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _save() async {
    if (_saving || _key.currentState?.validate() != true) return;
    // Validators above guarantee both schedule parts and a category.
    final startsAt = _combined;
    final category = _category;
    if (startsAt == null || category == null) return;
    final item = _original.copyWith(
      title: _title.text.trim(),
      location: _location.text.trim(),
      capacity: int.parse(_capacity.text.trim()),
      description: _description.text.trim(),
      clearDescription: _description.text.trim().isEmpty,
      startsAt: startsAt,
      category: category,
      online: _online,
    );
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _allowPop = true);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    Navigator.pop(context, item);
  }

  Future<void> _onPop(bool didPop, Workshop? result) async {
    if (didPop || _saving || _askingDiscard) return;
    _askingDiscard = true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your unsaved workshop changes will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    _askingDiscard = false;
    if (discard != true) return;
    setState(() => _allowPop = true);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    Navigator.pop(context);
  }

  void _dismiss(PointerDownEvent event) => FocusScope.of(context).unfocus();

  @override
  Widget build(BuildContext context) => PopScope<Workshop>(
    canPop: _allowPop || (!_dirty && !_saving),
    onPopInvokedWithResult: _onPop,
    child: Scaffold(
      appBar: AppBar(
        title: Text(widget.initial == null ? 'New workshop' : 'Edit workshop'),
      ),
      body: SafeArea(
        child: Form(
          key: _key,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: AbsorbPointer(
                  absorbing: _saving,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Bring people together.',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Share a skill, choose a time and open the studio.',
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _title,
                        focusNode: _titleFocus,
                        validator: _validateTitle,
                        maxLength: 60,
                        maxLengthEnforcement: MaxLengthEnforcement.none,
                        decoration: const InputDecoration(
                          labelText: 'Workshop title',
                        ),
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => _locationFocus.requestFocus(),
                        onTapOutside: _dismiss,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<WorkshopCategory>(
                        initialValue: _category,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        isExpanded: true,
                        items: WorkshopCategory.values
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Row(
                                  children: [
                                    Icon(category.icon),
                                    const SizedBox(width: 12),
                                    Text(category.label),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(() => _category = value),
                        validator: (value) =>
                            value == null ? 'Choose a category' : null,
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Online workshop'),
                        subtitle: const Text(
                          'Use a meeting link instead of a room',
                        ),
                        value: _online,
                        onChanged: (value) => setState(() => _online = value),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _location,
                        focusNode: _locationFocus,
                        validator: _validateLocation,
                        decoration: InputDecoration(
                          labelText: _online
                              ? 'Workshop link'
                              : 'Campus location',
                          prefixIcon: Icon(
                            _online ? Icons.link : Icons.place_outlined,
                          ),
                        ),
                        keyboardType: _online
                            ? TextInputType.url
                            : TextInputType.streetAddress,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => _capacityFocus.requestFocus(),
                        onTapOutside: _dismiss,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _dateText,
                        focusNode: _dateFocus,
                        readOnly: true,
                        onTap: _pickDate,
                        validator: (_) => _validateSchedule(true),
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          suffixIcon: Icon(Icons.calendar_month_outlined),
                        ),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => _timeFocus.requestFocus(),
                        onTapOutside: _dismiss,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _timeText,
                        focusNode: _timeFocus,
                        readOnly: true,
                        onTap: _pickTime,
                        validator: (_) => _validateSchedule(false),
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          suffixIcon: Icon(Icons.schedule),
                        ),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => _capacityFocus.requestFocus(),
                        onTapOutside: _dismiss,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _capacity,
                        focusNode: _capacityFocus,
                        validator: _validateCapacity,
                        decoration: const InputDecoration(
                          labelText: 'Places',
                          helperText: '1–500 makers',
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            _descriptionFocus.requestFocus(),
                        onTapOutside: _dismiss,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _description,
                        focusNode: _descriptionFocus,
                        validator: (_) => null,
                        decoration: const InputDecoration(
                          labelText: 'Description (optional)',
                        ),
                        minLines: 3,
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _save(),
                        onTapOutside: _dismiss,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check),
                        label: Text(_saving ? 'Saving…' : 'Save workshop'),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
