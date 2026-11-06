import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/di.dart';
import 'profile/view_model/profile_cubit.dart';
import 'profile/view_model/profile_intent.dart';

class ProfileScope extends StatefulWidget {
  const ProfileScope({required this.child, super.key});

  final Widget child;

  @override
  State<ProfileScope> createState() => _ProfileScopeState();
}

class _ProfileScopeState extends State<ProfileScope> {
  late final ProfileCubit _cubit = getIt<ProfileCubit>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _cubit.doIntent(const LoadProfileIntent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(value: _cubit, child: widget.child);
  }
}
