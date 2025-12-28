import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

class ParticipantVideoWidget extends StatelessWidget {
  final Participant participant;
  final bool isFullscreen;

  const ParticipantVideoWidget({
    super.key,
    required this.participant,
    this.isFullscreen = false,
  });

  @override
  Widget build(BuildContext context) {
    TrackPublication? videoPublication;
    final cameraTracks = participant.videoTrackPublications.where(
          (pub) => pub.source == TrackSource.camera,
    );

    if (cameraTracks.isNotEmpty) {
      videoPublication = cameraTracks.first;
    } else if (participant.videoTrackPublications.isNotEmpty) {
      videoPublication = participant.videoTrackPublications.first;
    }

    final bool isVideoEnabled =
        videoPublication != null &&
            !videoPublication.muted &&
            videoPublication.track != null;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F38),
        borderRadius: isFullscreen
            ? BorderRadius.zero
            : BorderRadius.circular(16),
        border: isFullscreen
            ? null
            : Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (isVideoEnabled)
            Positioned.fill(
              child: VideoTrackRenderer(
                videoPublication!.track as VideoTrack,
                fit: VideoViewFit.cover,
              ),
            )
          else
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(isFullscreen ? 30 : 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      color: Colors.white24,
                      size: isFullscreen ? 80 : 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    participant is LocalParticipant
                        ? "You"
                        : participant.identity,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: isFullscreen ? 18 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          if (!isFullscreen)
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      participant is LocalParticipant
                          ? "You"
                          : participant.identity,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      participant.isMicrophoneEnabled()
                          ? Icons.mic_rounded
                          : Icons.mic_off_rounded,
                      color: participant.isMicrophoneEnabled()
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}