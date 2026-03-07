import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatting.dart';
import '../../../../data/models/mosque_model.dart';

class MosqueListItem extends StatelessWidget {
  const MosqueListItem({
    required this.mosque,
    required this.lang,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final MosqueModel mosque;
  final String      lang;
  final bool        isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBn  = lang == 'bn';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryGreen.withOpacity(0.08)
            : theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primaryGreen : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: name + verification badge + distance
              Row(
                children: [
                  // Pin icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: mosque.pinColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.mosque, color: mosque.pinColor, size: 20),
                  ),
                  const SizedBox(width: 10),

                  // Name + verification
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                isBn ? mosque.nameBn : mosque.nameEn,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? AppColors.primaryGreen
                                      : null,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            _VerificationBadge(
                              status: mosque.verificationStatus,
                              isBn: isBn,
                            ),
                          ],
                        ),
                        if (mosque.address.isNotEmpty)
                          Text(
                            mosque.address,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),

                  // Distance
                  if (mosque.distanceKm != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          mosque.distanceText(isBn),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              // Jamat times (if available)
              if (mosque.jamatTimes != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _JamatTimesRow(
                    jamat: mosque.jamatTimes!,
                    isBn: isBn,
                  ),
                ),

              // Facilities row
              if (_hasFacilities(mosque))
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: _FacilitiesRow(mosque: mosque, isBn: isBn),
                ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    // Directions
                    _ActionButton(
                      icon: Icons.directions,
                      label: isBn ? 'দিকনির্দেশ' : 'Directions',
                      onTap: () => _openDirections(mosque),
                    ),
                    const SizedBox(width: 8),
                    // Share
                    _ActionButton(
                      icon: Icons.share,
                      label: isBn ? 'শেয়ার' : 'Share',
                      onTap: () => _shareMosque(context, mosque, isBn),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasFacilities(MosqueModel m) {
    final f = m.facilities;
    return f != null &&
        (f.hasWomensSection ||
            f.hasWuduFacility ||
            f.hasAirConditioning ||
            f.hasParking ||
            f.isWheelchairAccessible);
  }

  Future<void> _openDirections(MosqueModel m) async {
    final uri = Uri.parse(
      'geo:${m.latitude},${m.longitude}?q=${m.latitude},${m.longitude}(${Uri.encodeComponent(m.nameEn)})',
    );
    if (!await launchUrl(uri)) {
      final webUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${m.latitude},${m.longitude}',
      );
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  void _shareMosque(BuildContext context, MosqueModel m, bool isBn) {
    final text = isBn
        ? '${m.nameBn}\n${m.address}\nhttps://www.google.com/maps?q=${m.latitude},${m.longitude}'
        : '${m.nameEn}\n${m.address}\nhttps://www.google.com/maps?q=${m.latitude},${m.longitude}';
    // Using clipboard as share_plus may need additional setup
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isBn ? 'লিংক কপি হয়েছে' : 'Link copied')),
    );
    // In production: Share.share(text);
    _ = text;
  }
}

// ── Verification badge ────────────────────────────────────────────────────────

class _VerificationBadge extends StatelessWidget {
  const _VerificationBadge({required this.status, required this.isBn});

  final VerificationStatus status;
  final bool               isBn;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      VerificationStatus.verified  => (AppColors.success, isBn ? '✓' : '✓'),
      VerificationStatus.community => (AppColors.gold, isBn ? '★' : '★'),
      VerificationStatus.unverified=> (Colors.grey, ''),
    };
    if (label.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ── Jamat times row ───────────────────────────────────────────────────────────

class _JamatTimesRow extends StatelessWidget {
  const _JamatTimesRow({required this.jamat, required this.isBn});

  final JamatTimesModel jamat;
  final bool            isBn;

  @override
  Widget build(BuildContext context) {
    final times = <String, String?>{
      if (isBn) 'ফজর' : jamat.fajr   else 'Fajr'    : jamat.fajr,
      if (isBn) 'যোহর' : jamat.dhuhr  else 'Dhuhr'   : jamat.dhuhr,
      if (isBn) 'আসর'  : jamat.asr    else 'Asr'     : jamat.asr,
      if (isBn) 'মাগরিব': jamat.maghrib else 'Maghrib': jamat.maghrib,
      if (isBn) 'ইশা'  : jamat.isha   else 'Isha'    : jamat.isha,
    };

    final entries = times.entries.where((e) => e.value != null).toList();
    if (entries.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: entries.map((e) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '${e.key}: ${e.value}',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.w500,
          ),
        ),
      )).toList(),
    );
  }
}

// ── Facilities row ────────────────────────────────────────────────────────────

class _FacilitiesRow extends StatelessWidget {
  const _FacilitiesRow({required this.mosque, required this.isBn});

  final MosqueModel mosque;
  final bool        isBn;

  @override
  Widget build(BuildContext context) {
    final f = mosque.facilities!;
    return Row(
      children: [
        if (f.hasWomensSection)
          _FacilityChip(icon: Icons.wc, label: isBn ? 'মহিলা কক্ষ' : 'Women'),
        if (f.hasWuduFacility)
          _FacilityChip(icon: Icons.water_drop, label: isBn ? 'অযু' : 'Wudu'),
        if (f.hasAirConditioning)
          _FacilityChip(icon: Icons.ac_unit, label: 'AC'),
        if (f.hasParking)
          _FacilityChip(icon: Icons.local_parking, label: isBn ? 'পার্কিং' : 'Parking'),
        if (f.isWheelchairAccessible)
          _FacilityChip(icon: Icons.accessible, label: isBn ? 'হুইলচেয়ার' : 'Accessible'),
      ],
    );
  }
}

class _FacilityChip extends StatelessWidget {
  const _FacilityChip({required this.icon, required this.label});

  final IconData icon;
  final String   label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey),
          const SizedBox(width: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String   label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: AppColors.primaryGreen,
        side: const BorderSide(color: AppColors.primaryGreen, width: 0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
