import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/plan.dart';
import '../models/project.dart';
import '../services/category_storage.dart';
import '../services/plan_storage.dart';
import '../services/project_storage.dart';
import 'plan_add_screen.dart';
import 'project_add_screen.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({
    super.key,
    this.onChanged,
  });

  final VoidCallback? onChanged;

  @override
  State<PlanScreen> createState() =>
      _PlanScreenState();
}

class _PlanScreenState
    extends State<PlanScreen> {
  List<Plan> _plans = [];
  List<Project> _projects = [];
  List<PlanCategory> _categories = [];

  bool _loading = true;

  int _selectedWeekday =
      DateTime.now().weekday;

  String _filter = 'selected';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final plans =
        await PlanStorage.load();

    final projects =
        await ProjectStorage.load();

    final categories =
        await CategoryStorage.load();

    if (!mounted) return;

    setState(() {
      _plans = plans;
      _projects = projects;
      _categories = categories;
      _loading = false;
    });
  }

  DateTime get _selectedDate {
    final today =
        DateTime.now();

    final difference =
        _selectedWeekday -
        today.weekday;

    return DateTime(
      today.year,
      today.month,
      today.day + difference,
    );
  }

  String _dateKey(
    DateTime date,
  ) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  bool _isSameDay(
    DateTime a,
    DateTime b,
  ) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  bool _isPlanForDate(
    Plan plan,
    DateTime date,
  ) {
    if (!plan.hasDate) {
      return false;
    }

    if (date.isBefore(
      DateTime(
        plan.startDate.year,
        plan.startDate.month,
        plan.startDate.day,
      ),
    )) {
      return false;
    }

    if (plan.endDate != null &&
        date.isAfter(
          DateTime(
            plan.endDate!.year,
            plan.endDate!.month,
            plan.endDate!.day,
          ),
        )) {
      return false;
    }

    if (!plan.repeatEnabled) {
      return _isSameDay(
        plan.startDate,
        date,
      );
    }

    switch (plan.repeatType) {
      case 'daily':
        return true;

      case 'weekly':
        if (plan.repeatDays.isEmpty) {
          return date.weekday ==
              plan.startDate.weekday;
        }

        return plan.repeatDays.contains(
          date.weekday - 1,
        );

      case 'monthly':
        return date.day ==
            plan.startDate.day;

      default:
        return _isSameDay(
          plan.startDate,
          date,
        );
    }
  }

  List<Plan> get _visiblePlans {
    if (_filter == 'someday') {
      return _plans
          .where(
            (plan) =>
                plan.type ==
                    'someday' ||
                !plan.hasDate,
          )
          .toList();
    }

    if (_filter == 'all') {
      return List<Plan>.from(
        _plans,
      );
    }

    return _plans
        .where(
          (plan) =>
              _isPlanForDate(
            plan,
            _selectedDate,
          ),
        )
        .toList();
  }

  List<Plan> _sortedPlans(
    List<Plan> plans,
  ) {
    final result =
        List<Plan>.from(plans);

    result.sort(
      (a, b) {
        if (a.hasTime &&
            b.hasTime) {
          final aTime =
              (a.startHour ?? 0) *
                      60 +
                  (a.startMinute ?? 0);

          final bTime =
              (b.startHour ?? 0) *
                      60 +
                  (b.startMinute ?? 0);

          return aTime.compareTo(
            bTime,
          );
        }

        if (a.hasTime) return -1;
        if (b.hasTime) return 1;

        return a.createdAt.compareTo(
          b.createdAt,
        );
      },
    );

    return result;
  }

  bool _isCompleted(
    Plan plan,
  ) {
    final key =
        _dateKey(
      _filter == 'selected'
          ? _selectedDate
          : DateTime.now(),
    );

    return plan.completedDates
        .contains(key);
  }

  Future<void> _togglePlan(
    Plan plan,
  ) async {
    final key =
        _dateKey(
      _filter == 'selected'
          ? _selectedDate
          : DateTime.now(),
    );

    final completed =
        List<String>.from(
      plan.completedDates,
    );

    if (completed.contains(key)) {
      completed.remove(key);
    } else {
      completed.add(key);
    }

    final updated =
        plan.copyWith(
      completedDates:
          completed,
    );

    final index =
        _plans.indexWhere(
      (item) =>
          item.id == plan.id,
    );

    if (index == -1) return;

    setState(() {
      _plans[index] =
          updated;
    });

    await PlanStorage.save(
      _plans,
    );

    widget.onChanged?.call();
  }

  Future<void> _editPlan(
    Plan plan,
  ) async {
    final result =
        await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PlanAddScreen(
          plan: plan,
        ),
      ),
    );

    if (result == true) {
      await _loadData();
      widget.onChanged?.call();
    }
  }

  Future<void> _addPlan() async {
    final result =
        await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const PlanAddScreen(),
      ),
    );

    if (result == true) {
      await _loadData();
      widget.onChanged?.call();
    }
  }

  Future<void> _deletePlan(
    Plan plan,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) =>
          AlertDialog(
        title:
            const Text('계획 삭제'),
        content:
            Text(
          '"${plan.title}"을(를) 삭제할까요?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                false,
              );
            },
            child:
                const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                true,
              );
            },
            child:
                const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _plans.removeWhere(
        (item) =>
            item.id == plan.id,
      );
    });

    await PlanStorage.save(
      _plans,
    );

    widget.onChanged?.call();
  }

  Future<void> _addProject() async {
    final result =
        await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const ProjectAddScreen(),
      ),
    );

    if (result == true) {
      await _loadData();
      widget.onChanged?.call();
    }
  }

  Future<void> _toggleProjectTask(
    Project project,
    ProjectTask task,
  ) async {
    final updatedTasks =
        project.tasks.map(
      (item) {
        if (item.id == task.id) {
          return item.copyWith(
            completed:
                !item.completed,
          );
        }

        return item;
      },
    ).toList();

    final updated =
        project.copyWith(
      tasks: updatedTasks,
    );

    final index =
        _projects.indexWhere(
      (item) =>
          item.id == project.id,
    );

    if (index == -1) return;

    setState(() {
      _projects[index] =
          updated;
    });

    await ProjectStorage.save(
      _projects,
    );

    widget.onChanged?.call();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('계획'),
        actions: [
          IconButton(
            onPressed:
                _showMoreMenu,
            icon:
                const Icon(
              Icons.more_vert_rounded,
            ),
          ),
        ],
      ),

      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding:
                    const EdgeInsets.fromLTRB(
                  16,
                  4,
                  16,
                  30,
                ),
                children: [
                  _buildWeekSelector(),

                  const SizedBox(
                    height: 16,
                  ),

                  _buildFilterSelector(),

                  const SizedBox(
                    height: 20,
                  ),

                  _buildPlanList(),

                  const SizedBox(
                    height: 28,
                  ),

                  _buildProjectSection(),
                ],
              ),
            ),

      floatingActionButton:
          FloatingActionButton(
        onPressed: _addPlan,
        child:
            const Icon(
          Icons.add_rounded,
        ),
      ),
    );
  }

  Widget _buildWeekSelector() {
    const weekdays = [
      '월',
      '화',
      '수',
      '목',
      '금',
      '토',
      '일',
    ];

    return Column(
      children: [
        Row(
          children:
              List.generate(
            7,
            (index) {
              final weekday =
                  index + 1;

              final selected =
                  weekday ==
                      _selectedWeekday;

              final today =
                  weekday ==
                      DateTime.now()
                          .weekday;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedWeekday =
                          weekday;
                      _filter =
                          'selected';
                    });
                  },
                  child:
                      Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 8,
                    ),
                    child:
                        Column(
                      children: [
                        Text(
                          weekdays[
                              index],
                          style:
                              TextStyle(
                            fontSize:
                                13,
                            fontWeight:
                                selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            color:
                                selected
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primary
                                    : Colors
                                        .grey
                                        .shade600,
                          ),
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        Container(
                          width: 34,
                          height: 34,
                          alignment:
                              Alignment
                                  .center,
                          decoration:
                              BoxDecoration(
                            color: selected
                                ? Theme.of(
                                    context,
                                  )
                                    .colorScheme
                                    .primary
                                : Colors
                                    .transparent,
                            shape: BoxShape
                                .circle,
                          ),
                          child:
                              Text(
                            _dateForWeekday(
                              weekday,
                            ).day.toString(),
                            style:
                                TextStyle(
                              fontSize:
                                  14,
                              fontWeight:
                                  FontWeight
                                      .w600,
                              color: selected
                                  ? Colors
                                      .white
                                  : Colors
                                      .black87,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        if (today)
                          Container(
                            width: 4,
                            height: 4,
                            decoration:
                                BoxDecoration(
                              color: Theme.of(
                                context,
                              )
                                  .colorScheme
                                  .primary,
                              shape:
                                  BoxShape
                                      .circle,
                            ),
                          )
                        else
                          const SizedBox(
                            height: 4,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Divider(
          height: 1,
          color:
              Colors.grey.shade200,
        ),
      ],
    );
  }

  DateTime _dateForWeekday(
    int weekday,
  ) {
    final today =
        DateTime.now();

    return DateTime(
      today.year,
      today.month,
      today.day +
          weekday -
          today.weekday,
    );
  }

  Widget _buildFilterSelector() {
    return Row(
      children: [
        _filterButton(
          title: '선택일',
          value: 'selected',
        ),
        const SizedBox(
          width: 8,
        ),
        _filterButton(
          title: '언젠가',
          value: 'someday',
        ),
        const SizedBox(
          width: 8,
        ),
        _filterButton(
          title: '전체',
          value: 'all',
        ),
      ],
    );
  }

  Widget _filterButton({
    required String title,
    required String value,
  }) {
    final selected =
        _filter == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _filter = value;
          });
        },
        child: Container(
          padding:
              const EdgeInsets.symmetric(
            vertical: 10,
          ),
          decoration:
              BoxDecoration(
            color: selected
                ? Theme.of(context)
                    .colorScheme
                    .primary
                : Colors.grey.shade100,
            borderRadius:
                BorderRadius.circular(
              10,
            ),
          ),
          alignment:
              Alignment.center,
          child: Text(
            title,
            style:
                TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.w600,
              color: selected
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanList() {
    final plans =
        _sortedPlans(
      _visiblePlans,
    );

    if (plans.isEmpty) {
      return Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 45,
        ),
        child: Center(
          child: Text(
            _filter == 'someday'
                ? '언젠가 할 일이 없어요.'
                : '등록된 계획이 없어요.',
            style:
                TextStyle(
              color:
                  Colors.grey.shade500,
            ),
          ),
        ),
      );
    }

    return Column(
      children:
          plans.map(
        _buildPlanTile,
      ).toList(),
    );
  }

  Widget _buildPlanTile(
    Plan plan,
  ) {
    final completed =
        _isCompleted(plan);

    final category =
        _findCategory(
      plan.category,
    );

    final categoryColor =
        category == null
            ? Colors.grey
            : Color(
                category.colorValue,
              );

    return InkWell(
      borderRadius:
          BorderRadius.circular(10),
      onTap: () {
        _editPlan(plan);
      },
      child: Container(
        margin:
            const EdgeInsets.only(
          bottom: 3,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment
                    .stretch,
            children: [
              // 카테고리 색상 세로선
              Container(
                width: 3,
                margin:
                    const EdgeInsets
                        .symmetric(
                  vertical: 6,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      categoryColor,
                  borderRadius:
                      BorderRadius
                          .circular(
                    3,
                  ),
                ),
              ),

              const SizedBox(
                width: 11,
              ),

              GestureDetector(
                onTap: () {
                  _togglePlan(plan);
                },
                child: SizedBox(
                  width: 27,
                  child: Center(
                    child: Text(
                      completed
                          ? '✓'
                          : _symbolForPlan(
                              plan,
                            ),
                      style:
                          TextStyle(
                        fontSize: 21,
                        fontWeight:
                            FontWeight.w500,
                        color: completed
                            ? Colors
                                .grey
                            : Colors
                                .black87,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 5,
              ),

              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 9,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        plan.title,
                        style:
                            TextStyle(
                          fontSize:
                              15,
                          decoration:
                              completed
                                  ? TextDecoration
                                      .lineThrough
                                  : null,
                          color: completed
                              ? Colors
                                  .grey
                              : Colors
                                  .black87,
                        ),
                      ),
                      if (plan.hasTime)
                        Padding(
                          padding:
                              const EdgeInsets
                                  .only(
                            top: 3,
                          ),
                          child: Text(
                            _timeText(
                              plan,
                            ),
                            style:
                                TextStyle(
                              fontSize:
                                  11,
                              color: Colors
                                  .grey
                                  .shade600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              if (plan.category
                  .isNotEmpty)
                Center(
                  child:
                      Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          categoryColor
                              .withValues(
                        alpha: 0.10,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        5,
                      ),
                    ),
                    child: Text(
                      plan.category,
                      style:
                          TextStyle(
                        fontSize: 10,
                        color:
                            categoryColor,
                      ),
                    ),
                  ),
                ),

              PopupMenuButton<
                  String>(
                padding:
                    EdgeInsets.zero,
                icon:
                    const Icon(
                  Icons.more_vert,
                  size: 19,
                ),
                onSelected:
                    (value) {
                  if (value ==
                      'edit') {
                    _editPlan(
                      plan,
                    );
                  }

                  if (value ==
                      'delete') {
                    _deletePlan(
                      plan,
                    );
                  }
                },
                itemBuilder:
                    (context) =>
                        const [
                  PopupMenuItem(
                    value: 'edit',
                    child:
                        Text('수정'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child:
                        Text('삭제'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectSection() {
    if (_projects.isEmpty) {
      return Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '프로젝트',
                  style:
                      TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed:
                    _addProject,
                icon:
                    const Icon(
                  Icons.add,
                  size: 17,
                ),
                label:
                    const Text(
                  '프로젝트',
                ),
              ),
            ],
          ),
          Text(
            '진행 중인 프로젝트가 없어요.',
            style:
                TextStyle(
              color:
                  Colors.grey.shade500,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                '프로젝트',
                style:
                    TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
            TextButton.icon(
              onPressed:
                  _addProject,
              icon:
                  const Icon(
                Icons.add,
                size: 17,
              ),
              label:
                  const Text(
                '프로젝트',
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 6,
        ),

        ..._projects.map(
          _buildProjectCard,
        ),
      ],
    );
  }

  Widget _buildProjectCard(
    Project project,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.grey.shade50,
        borderRadius:
            BorderRadius.circular(
          12,
        ),
        border: Border.all(
          color:
              Colors.grey.shade200,
        ),
      ),
      child: ExpansionTile(
        title:
            Text(
          project.title,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.w600,
          ),
        ),
        subtitle:
            Text(
          '${project.completedTaskCount}/${project.tasks.length} 완료',
        ),
        children: [
          if (project.tasks.isEmpty)
            const Padding(
              padding:
                  EdgeInsets.all(16),
              child:
                  Text(
                '세부 작업이 없어요.',
              ),
            ),
          ...project.tasks.map(
            (task) =>
                CheckboxListTile(
              value:
                  task.completed,
              title:
                  Text(
                task.title,
                style:
                    TextStyle(
                  decoration:
                      task.completed
                          ? TextDecoration
                              .lineThrough
                          : null,
                ),
              ),
              onChanged: (_) {
                _toggleProjectTask(
                  project,
                  task,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void>
      _showMoreMenu() async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              ListTile(
                leading:
                    const Icon(
                  Icons.add_task_rounded,
                ),
                title:
                    const Text(
                  '계획 추가',
                ),
                onTap: () {
                  Navigator.pop(
                    context,
                  );
                  _addPlan();
                },
              ),
              ListTile(
                leading:
                    const Icon(
                  Icons.folder_outlined,
                ),
                title:
                    const Text(
                  '프로젝트 추가',
                ),
                onTap: () {
                  Navigator.pop(
                    context,
                  );
                  _addProject();
                },
              ),
              ListTile(
                leading:
                    const Icon(
                  Icons.label_outline,
                ),
                title:
                    const Text(
                  '카테고리 관리',
                ),
                onTap: () {
                  Navigator.pop(
                    context,
                  );
                  _showCategoryManager();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void>
      _showCategoryManager() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  4,
                  20,
                  20,
                ),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    const Text(
                      '카테고리',
                      style:
                          TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    ..._categories.map(
                      (category) {
                        return ListTile(
                          contentPadding:
                              EdgeInsets.zero,
                          leading:
                              Container(
                            width: 12,
                            height: 12,
                            decoration:
                                BoxDecoration(
                              color:
                                  Color(
                                category
                                    .colorValue,
                              ),
                              shape:
                                  BoxShape
                                      .circle,
                            ),
                          ),
                          title:
                              Text(
                            category.name,
                          ),
                          trailing:
                              Row(
                            mainAxisSize:
                                MainAxisSize
                                    .min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(
                                  Icons.edit_outlined,
                                  size: 20,
                                ),
                                onPressed:
                                    () async {
                                  final result =
                                      await _showCategoryEditor(
                                    category,
                                  );

                                  if (result !=
                                      null) {
                                    final index =
                                        _categories.indexWhere(
                                      (item) =>
                                          item.id ==
                                          category.id,
                                    );

                                    if (index !=
                                        -1) {
                                      _categories[
                                              index] =
                                          result;

                                      await CategoryStorage
                                          .save(
                                        _categories,
                                      );

                                      await _loadData();

                                      setSheetState(
                                        () {},
                                      );
                                    }
                                  }
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                ),
                                onPressed:
                                    () async {
                                  await _deleteCategory(
                                    category,
                                  );

                                  setSheetState(
                                    () {},
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    SizedBox(
                      width:
                          double.infinity,
                      child:
                          OutlinedButton.icon(
                        onPressed:
                            () async {
                          final result =
                              await _showCategoryEditor(
                            null,
                          );

                          if (result !=
                              null) {
                            _categories
                                .add(
                              result,
                            );

                            await CategoryStorage
                                .save(
                              _categories,
                            );

                            await _loadData();

                            setSheetState(
                              () {},
                            );
                          }
                        },
                        icon:
                            const Icon(
                          Icons.add,
                        ),
                        label:
                            const Text(
                          '카테고리 추가',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    await _loadData();
  }

  Future<PlanCategory?>
      _showCategoryEditor(
    PlanCategory? category,
  ) async {
    final controller =
        TextEditingController(
      text:
          category?.name ?? '',
    );

    int selectedColor =
        category?.colorValue ??
            0xFF5B8DEF;

    const colors = [
      0xFF5B8DEF,
      0xFF4CAF7D,
      0xFFFF9F68,
      0xFFE77D9A,
      0xFF9B7EDE,
      0xFF4B9CD3,
      0xFFD98BC3,
      0xFFE0A458,
      0xFF8E9AAF,
      0xFFEF5350,
      0xFF26A69A,
      0xFF78909C,
    ];

    final result =
        await showDialog<PlanCategory>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setState) {
            return AlertDialog(
              title: Text(
                category == null
                    ? '카테고리 추가'
                    : '카테고리 수정',
              ),
              content: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  TextField(
                    controller:
                        controller,
                    autofocus:
                        true,
                    decoration:
                        const InputDecoration(
                      labelText:
                          '카테고리 이름',
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  const Align(
                    alignment:
                        Alignment
                            .centerLeft,
                    child: Text(
                      '색상',
                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight
                                .w600,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children:
                        colors.map(
                      (color) {
                        final selected =
                            selectedColor ==
                                color;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor =
                                  color;
                            });
                          },
                          child:
                              Container(
                            width: 34,
                            height: 34,
                            decoration:
                                BoxDecoration(
                              color:
                                  Color(
                                color,
                              ),
                              shape:
                                  BoxShape
                                      .circle,
                              border:
                                  selected
                                      ? Border.all(
                                          color:
                                              Colors.black87,
                                          width:
                                              3,
                                        )
                                      : null,
                            ),
                            child:
                                selected
                                    ? const Icon(
                                        Icons.check,
                                        color:
                                            Colors.white,
                                        size:
                                            18,
                                      )
                                    : null,
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },
                  child:
                      const Text(
                    '취소',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final name =
                        controller
                            .text
                            .trim();

                    if (name.isEmpty) {
                      return;
                    }

                    Navigator.pop(
                      context,
                      PlanCategory(
                        id: category
                                ?.id ??
                            DateTime.now()
                                .microsecondsSinceEpoch
                                .toString(),
                        name: name,
                        colorValue:
                            selectedColor,
                      ),
                    );
                  },
                  child:
                      const Text(
                    '저장',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();

    return result;
  }

  Future<void> _deleteCategory(
    PlanCategory category,
  ) async {
    if (_categories.length <= 1) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            '카테고리는 최소 1개가 필요합니다.',
          ),
        ),
      );
      return;
    }

    final used =
        _plans.any(
      (plan) =>
          plan.category ==
          category.name,
    );

    if (used) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            '${category.name} 카테고리를 사용하는 계획이 있어요.',
          ),
        ),
      );
      return;
    }

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) =>
          AlertDialog(
        title:
            const Text(
          '카테고리 삭제',
        ),
        content:
            Text(
          '"${category.name}"을(를) 삭제할까요?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                false,
              );
            },
            child:
                const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                true,
              );
            },
            child:
                const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    _categories.removeWhere(
      (item) =>
          item.id ==
          category.id,
    );

    await CategoryStorage.save(
      _categories,
    );

    setState(() {});
  }

  PlanCategory? _findCategory(
    String name,
  ) {
    for (final category
        in _categories) {
      if (category.name ==
          name) {
        return category;
      }
    }

    return null;
  }

  String _symbolForPlan(
    Plan plan,
  ) {
    switch (plan.type) {
      case 'repeat':
        return '↻';

      case 'someday':
        return '□';

      default:
        return '○';
    }
  }

  String _timeText(
    Plan plan,
  ) {
    if (!plan.hasTime ||
        plan.startHour == null ||
        plan.startMinute == null) {
      return '';
    }

    final start =
        '${plan.startHour!.toString().padLeft(2, '0')}:'
        '${plan.startMinute!.toString().padLeft(2, '0')}';

    if (plan.endHour == null ||
        plan.endMinute == null) {
      return start;
    }

    final end =
        '${plan.endHour!.toString().padLeft(2, '0')}:'
        '${plan.endMinute!.toString().padLeft(2, '0')}';

    return '$start – $end';
  }
}