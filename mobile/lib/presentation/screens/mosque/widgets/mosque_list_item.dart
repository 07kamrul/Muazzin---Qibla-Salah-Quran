import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
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
    final isBn  = lang == 'bn';
    final addr  = (isBn ? mosque.addressBn : mosque.addressEn) ??
        [mosque.upazila, mosque.district]
            .where((s) => s.isNotEmpty)
            .join(', ');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0x281F5C3A), AppColors.sky3],
              )
            : null,
        color: isSelected ? null : AppColors.sky3,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? AppColors.domeBd
              : AppColors.goldBd.withOpacity(0.4),
          width: isSelected ? 1.5 : 0.8,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: name + verification badge + distance
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: mosque.pinColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.mosque, color: mosque.pinColor, size: 20),
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                isBn ? mosque.nameBn : mosque.nameEn,
                                style: TextStyle(
                                  fontFamily: 'NotoSansBengali',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? AppColors.domePale
                                      : AppColors.marble,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 5),
                            _VerificationBadge(
                              status: mosque.verificationStatus,
                              isBn: isBn,
                            ),
                          ],
                        ),
                        if (addr.isNotEmpty)
                          Text(
                            addr,
                            style: const TextStyle(
                              fontFamily: 'NotoSansBengali',
                              fontSize: 11,
                              color: AppColors.sandMid,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),

                  if (mosque.distanceKm != null)
                    Text(
                      mosque.distanceText(lang),
                      style: const TextStyle(
                        fontFamily: 'NotoSansBengali',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.domePale,
                      ),
                    ),
                ],
              ),

              // Jamat times (if available)
              if (mosque.jamatTimes.hasAny)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _JamatTimesRow(
                    jamat: mosque.jamatTimes,
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
    return f.womensSection || f.wudu || f.ac || f.parking || f.wheelchair;
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isBn ? 'লিংক কপি হয়েছে' : 'Link copied')),
    );
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
      VerificationStatus.verified   => (AppColors.domePale, '✓'),
      VerificationStatus.community  => (AppColors.goldWarm,  '★'),
      VerificationStatus.unverified => (AppColors.sandMid,   ''),
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
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.domeGlow,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: AppColors.domeBd),
        ),
        child: Text(
          '${e.key}: ${e.value}',
          style: const TextStyle(
            fontFamily: 'NotoSansBengali',
            fontSize: 10.5,
            color: AppColors.domePale,
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
    final f = mosque.facilities;
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        if (f.womensSection)
          _FacilityChip(icon: Icons.wc, label: isBn ? 'মহিলা' : 'Women'),
        if (f.wudu)
          _FacilityChip(icon: Icons.water_drop, label: isBn ? 'অযু' : 'Wudu'),
        if (f.ac)
          _FacilityChip(icon: Icons.ac_unit, label: 'AC'),
        if (f.parking)
          _FacilityChip(icon: Icons.local_parking, label: isBn ? 'পার্কিং' : 'Parking'),
        if (f.wheelchair)
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: AppColors.sandMid),
        const SizedBox(width: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.sandMid,
            fontFamily: 'NotoSansBengali',
          ),
        ),
      ],
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.domeGlow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.domeBd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppColors.domePale),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'NotoSansBengali',
                fontSize: 12,
                color: AppColors.domePale,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
